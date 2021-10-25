-module(bootstrap).
-export([main/0, reload_counter/0]).

add_code_paths() ->
  BasePath = "/Users/maharj/Development/elixir/counter/",
  JasonPath = string:concat(BasePath, "_build/dev/lib/jason/ebin/"),
  CounterPath = string:concat(BasePath, "_build/dev/lib/Elixir.Counter/ebin/"),
  cloudi_service_api:code_path_add("/usr/local/lib/elixir/ebin", 5000),
  cloudi_service_api:code_path_add(JasonPath, 5000),
  cloudi_service_api:code_path_add(CounterPath, 5000).

contains_url(Url, Services) ->
  lists:any(fun({_,{_,ServiceUrl,_,_,_,_,_,_,_,_,_,_,_,_}}) ->
       Url == ServiceUrl
     end, Services).

start_if_not_exists(Prefix, ServiceFn) ->
  {ok, Services} = cloudi_service_api:services(5000),
  case contains_url(Prefix, Services) of
    false ->
      io:fwrite("Creating service ~p...\n", [Prefix]),
      ServiceFn(Prefix);
    true ->
      already_exists
  end.

create_db(Prefix) ->
  {ok, [{db_password, Password}, {hostname, Hostname}, {port, Port}, {username, Username}, {database, Database}]} =
    file:consult(".dev.erl"),
  cloudi_service_api:services_add(
   [[{prefix, Prefix},
    {module, cloudi_service_db_pgsql},
    {args, [{driver, epgsql},
       {output, internal},
       {internal_interface, native},
       {hostname, Hostname},
       {port, Port},
       {database, Database},
       {username, Username},
       {password, Password},
       {default_debug_level, debug},
       {debug, true}]}]],
     5000
   ).

create_filesystem(Prefix) ->
  cloudi_service_api:services_add(
    [[{prefix, Prefix},
       {module, cloudi_service_filesystem},
       {args,
        [{directory, "/Users/maharj/Development/elixir/counter/public"},
         {refresh, 1}]},
       {dest_refresh, none},
       {count_process, 4}]],
    5000
 ).

create_counter(Prefix) ->
  cloudi_service_api:services_add(
    [[{prefix, Prefix},
      {module, 'Elixir.Counter'},
      {count_process, 5}]],
    5000
  ).

add_dependent_services() ->
  start_if_not_exists("/db/", fun create_db/1),
  start_if_not_exists("/counter/", fun create_counter/1),
  start_if_not_exists("/client/", fun create_filesystem/1).

reload_counter() ->
  cloudi_service_api:services_update(
    [{"",
      [{module, 'Elixir.Counter'},
       {modules_load, ['Elixir.Counter']}]}],
    5000
   ).

main() ->
  add_code_paths(),
  add_dependent_services().
