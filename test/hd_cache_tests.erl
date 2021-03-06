-module(hd_cache_tests).

-include_lib("eunit/include/eunit.hrl").

-define(APPLICATION, "eunit-pt").
-define(FILENAME,    "eunit.test").
-define(MSG1,        "eunit write test").
-define(MSG2,        "eunit double write test").

% weird path so seperate from other tests
configured_path_test() ->
    ConfiguredCachePath = "Yes, this is my cache path!",
    application:set_env(?APPLICATION, cache_path, ConfiguredCachePath),
    hd_cache:start_link(?APPLICATION),
    ConfiguredCachePath = hd_cache:get_path(),
    hd_cache:stop(),
    application:unset_env(?APPLICATION, cache_path).

% make sure age is between before and after write timestamp    
age_test() ->
    hd_cache:start_link(?APPLICATION),
    TimeBeforeWrite = erlang:system_time(second),
    hd_cache:write_file(?FILENAME, "age test"),
    WriteAge = hd_cache:age(?FILENAME),
    TimeAfterWrite = erlang:system_time(second),
    ?assert(erlang:system_time(second) - TimeBeforeWrite >= WriteAge),
    ?assert(erlang:system_time(second) - TimeAfterWrite =< WriteAge),
    hd_cache:stop().

% make sure touch is between before and after touch timestamp
touch_test() ->
    hd_cache:start_link(?APPLICATION),
    hd_cache:write_file(?FILENAME, "touch test"),
    TimeBeforeTouch = erlang:system_time(second),
    hd_cache:touch(?FILENAME),
    TouchAge = hd_cache:age(?FILENAME),
    TimeAfterTouch = erlang:system_time(second),
    ?assert(erlang:system_time(second) - TimeBeforeTouch >= TouchAge),
    ?assert(erlang:system_time(second) - TimeAfterTouch =< TouchAge),
    hd_cache:stop().

% actual API tests
setup()             -> hd_cache:start_link(?APPLICATION).
cleanup({ok, _Pid}) -> hd_cache:stop().
hd_cache_test_() ->
    {setup, fun setup/0, fun cleanup/1,
     [
      % differs per platform, just make sure it is "sane"
      ?_assert(is_list(hd_cache:get_path())),

      % write + read test, it should match
      ?_assertEqual(ok, hd_cache:write_file(?FILENAME, ?MSG1)),
      ?_assertEqual({ok, list_to_binary(?MSG1)}, hd_cache:read_file(?FILENAME)),

      % make sure write_file "overrides"
      ?_assertEqual(ok, hd_cache:write_file(?FILENAME, ?MSG2)),
      ?_assertEqual({ok, list_to_binary(?MSG2)}, hd_cache:read_file(?FILENAME)),

      % check md5
      ?_assertEqual(<<"185eb09397f65a765b81a13de396fb79">>, hd_cache:md5(?FILENAME))
     ]
    }.
