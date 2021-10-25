defmodule Counter do
  import CloudILogger
  require Jason

  @moduledoc """
  Basic CloudI external service implementation with HTTP REST and
  Websocket update support.
  """

  def cloudi_service_init(_args, _prefix, _timeout, dispatcher) do
    log_debug('Starting service.', [])
    :cloudi_service.subscribe(dispatcher, 'increment/get')
    :cloudi_service.subscribe(dispatcher, 'stream/get')
    :cloudi_service.subscribe(dispatcher, 'stream/notify')
    {:ok, :undefined}
  end

  def handle_increment(
        _info,
        state,
        dispatcher
      ) do
    case :cloudi_service_db_pgsql.transaction(
           dispatcher,
           '/db/maharj',
           [
             'INSERT INTO counter_event (created, event) VALUES (now(), \'increment\');',
             'UPDATE counter SET current_value = current_value + 1 WHERE id = (select max(id) from counter);'
           ]
         ) do
      {{:ok, :ok}, _} ->
        {:ok, count} = get_counter_value(dispatcher)

        :cloudi_service.send_async(
          dispatcher,
          '/counter/stream/notify',
          {:count, count}
        )

        response_info = :cloudi_request_info.key_value_new([{"status", "201"}])
        {:reply, response_info, "", state}

      {{:error, _}, _} ->
        response_info = :cloudi_request_info.key_value_new([{"status", "500"}])
        {:reply, response_info, "", state}
    end
  end

  def notify_websockets(dispatcher, message) do
    case :cloudi_service.mcast_async(
           dispatcher,
           '/counter/stream/websocket',
           Jason.encode!(message)
         ) do
      {:ok, ids} ->
        Enum.map(ids, fn id -> :cloudi_service.recv_async(dispatcher, id) end)

      _ ->
        log_error('send error!', [])
    end
  end

  def get_counter_value(dispatcher) do
    case :cloudi_service_db_pgsql.squery(
           dispatcher,
           '/db/maharj',
           'SELECT current_value as count FROM counter ORDER by id desc LIMIT 1'
         ) do
      {{:ok, {:ok, _, [{count} | _]}}, _} ->
        {:ok, String.to_integer(count)}

      {error, _} ->
        error
    end
  end

  def handle_stream(
        _info,
        state,
        dispatcher,
        _request
      ) do
    case get_counter_value(dispatcher) do
      {:ok, count} ->
        {:reply, Jason.encode!(%{"counter" => count}), state}

      {:error, _} ->
        response_info = :cloudi_request_info.key_value_new([{"status", "500"}])
        {:reply, response_info, "", state}
    end
  end

  def cloudi_service_handle_request(
        _request_type,
        name,
        _pattern,
        request_info,
        request,
        _timeout,
        _priority,
        _transid,
        _pid,
        state,
        dispatcher
      ) do
    info = :cloudi_request_info.key_value_parse(request_info)

    case name do
      '/counter/increment/get' ->
        handle_increment(info, state, dispatcher)

      '/counter/stream/get' ->
        handle_stream(info, state, dispatcher, request)

      '/counter/stream/notify' ->
        {:count, current} = request

        notify_websockets(dispatcher, %{
          "counter" => current,
          "notification" => true
        })

        {:noreply, state}

      _ ->
        response_info = :cloudi_request_info.key_value_new([{"status", "404"}])
        {:reply, response_info, Jason.encode!(%{"unknown" => name}), state}
    end
  end

  def cloudi_service_handle_info(request, state, _dispatcher) do
    log_warn('Unknown info "~p"', [request])
    {:noreply, state}
  end

  def cloudi_service_terminate(_reason, _timeout, _state) do
    :ok
  end
end
