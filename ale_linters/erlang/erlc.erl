#!/usr/bin/env escript

% This is a simple linter for erlang. For compatibility with rebar3
% erlc.erl specifies paths for libraties and other compiler options.

main([Orig, Buf]) ->
    case file_type(Buf) of
        escript ->
            Port = open_port(
                {spawn_executable, "/usr/bin/env"},
                [exit_status, nouse_stdio, {args, ["escript", "-s", Buf]}]),
            receive
                {Port, {exit_status, Status}} ->
                    halt(Status)
            end;
        module ->
            Default = [strong_validation, report],
            {ProjectDir, OptsDirs} = erl_opts_i(Orig),
            Opts = Default ++ OptsDirs ++ erl_opts(ProjectDir),
            case compile:file(Buf, Opts) of
                {ok, _} -> halt(0);
                error -> halt(1)
            end
    end.

-spec file_type(string()) -> module | escript.
file_type(File) ->
    {ok, Fd} = file:open(File, [raw, read]),
    try
        case file:read(Fd, 2) of
            {ok, "#!"} -> escript;
            _ -> module
        end
    after
        ok = file:close(Fd)
    end.

-spec erl_opts_i(string()) -> {string(), [compile:option()]}.
erl_opts_i(Orig) ->
    case filename:basename(filename:dirname(Orig)) of
        "src" ->
            Dir = filename:dirname(filename:dirname(Orig)),
            ProjectDir =
                case filename:basename(filename:dirname(Dir)) of
                    "apps" ->
                        filename:dirname(filename:dirname(Dir));
                    _Dir ->
                        Dir
                end,
            IncludeDir = filename:join(Dir, "include"),
            DepsDir = filename:join(ProjectDir, "_build/default/lib"),
            {ProjectDir, [{i, IncludeDir}, {i, DepsDir}]};
        _ ->
            {filename:dirname(Orig), []}
    end.

-spec erl_opts(string()) -> [compile:option()].
erl_opts(ProjectDir) ->
    RebarConfig = filename:join(ProjectDir, "rebar.config"),
    case file:consult(RebarConfig) of
        {ok, Config} ->
            case lists:keyfind(erl_opts, 1, Config) of
                {erl_opts, Opts} ->
                    erl_opts(ProjectDir, Opts, []);
                false ->
                    []
            end;
        {error, _Reason} ->
            []
    end.

-spec erl_opts(string(), [term()], [string()]) -> [compile:option()].
erl_opts(_ProjectDir, [], Acc) ->
    Acc;
erl_opts(ProjectDir, [{i, Dir}|Opts], Acc) ->
    erl_opts(ProjectDir, Opts, [{i, filename:join(ProjectDir, Dir)} | Acc]);
erl_opts(ProjectDir, Opts, [{d, Define}|Acc]) ->
    erl_opts(ProjectDir, Opts, [{d, Define} | Acc]);
erl_opts(ProjectDir, Opts, [{d, Key, Value}|Acc]) ->
    erl_opts(ProjectDir, Opts, [{d, Key, Value} | Acc]);
erl_opts(ProjectDir, Opts, [{parse_transform, Module}|Acc]) ->
    erl_opts(ProjectDir, [{parse_transform, Module}|Opts], Acc);
erl_opts(ProjectDir, Opts, [{platform_define, ArchRegex, Key}|Acc]) ->
    erl_opts(ProjectDir, Opts,
        case is_arch(ArchRegex) of
            true -> [{d, Key} | Acc];
            false -> Acc
        end);
erl_opts(ProjectDir, [{platform_define, ArchRegex, Key, Value}|Opts], Acc) ->
    erl_opts(ProjectDir, Opts,
        case is_arch(ArchRegex) of
            true -> [{d, Key, Value} | Acc];
            false -> Acc
        end);
erl_opts(ProjectDir, [_Opt|Opts], Acc) ->
    erl_opts(ProjectDir, Opts, Acc).

-spec is_arch(ArchRegex :: string()) -> boolean().
is_arch(ArchRegex) ->
    re:run(get_arch(), ArchRegex, [{capture, none}]) =:= match.

-spec get_arch() -> string().
get_arch() ->
    erlang:system_info(otp_release) ++ "-"
        ++ erlang:system_info(system_architecture) ++ "-"
        ++ wordsize().

-spec wordsize() -> string().
wordsize() ->
    try erlang:system_info({wordsize, external}) of
        Val ->
            integer_to_list(8 * Val)
    catch
        error:badarg ->
            integer_to_list(8 * erlang:system_info(wordsize))
    end.
