-module(hd_cache_tests).
-include_lib("eunit/include/eunit.hrl").

-define(APPLICATION, "eunit-pt").

configured_path_test() ->
    ConfiguredCachePath = "Yes, this is my cache path!",
    application:set_env(?APPLICATION, cache_path, ConfiguredCachePath),
    hd_cache:start_link(?APPLICATION),
    ConfiguredCachePath = hd_cache:get_path(),
    hd_cache:stop(),
    application:unset_env(?APPLICATION, cache_path).

setup() ->
    hd_cache:start_link(?APPLICATION).

cleanup({ok, _Pid}) ->
    hd_cache:stop().

hd_cache_test_() ->
    Filename = "eunit.test",
    Msg1 = "eunit write test",
    Msg2 = "eunit double write test",
    {setup, fun setup/0, fun cleanup/1,
     [?_assert(is_list(hd_cache:get_path()) =:= true),
      ?_assert(hd_cache:write_file(Filename, Msg1) =:= ok),
      ?_assert(hd_cache:read_file(Filename) =:= {ok, list_to_binary(Msg1)}),
      ?_assert(hd_cache:write_file(Filename, Msg2) =:= ok),
      ?_assert(hd_cache:read_file(Filename) =:= {ok, list_to_binary(Msg2)})
     ]
    }.
