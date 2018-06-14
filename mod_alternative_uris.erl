%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2015 Marc Worrell
%% @doc Support alternative uris and hostnames for a resource

%% Copyright 2015 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(mod_alternative_uris).
-author("Marc Worrell <marc@worrell.nl>").

-mod_title("Alternate Page Uris").
-mod_description("Define alternative uris for a resource.").
-mod_prio(300).
-mod_schema(1).

-export([
    observe_pivot_update/3,
    observe_dispatch_host/2,
    observe_dispatch/2,
    observe_rsc_merge/2,
    manage_schema/2
]).

-include_lib("zotonic.hrl").

%% @doc Update the lookup table for alternative uris
observe_pivot_update(#pivot_update{id=Id}, Props, Context) ->
    _ = m_alternative_uris:insert(Id, m_rsc:p_no_acl(Id, alternative_uris, Context), Context),
    Props.

%% @doc Called when the host didn't match any site config
observe_dispatch_host(#dispatch_host{host=Host, path=Path}, Context) ->
    case m_alternative_uris:list_dispatch_host(Host, Path, Context) of
        [{BestPath,_,_}=Best|Rest] ->
            {ok, {RscId,IsPerm}} = select_best(Rest, size(BestPath), Best),
            {ok, #dispatch_redirect{location=m_rsc:p(RscId, page_url, Context), is_permanent=IsPerm}};
        [] ->
            undefined
    end.

%% @doc Called when the path didn't match any dispatch rule
observe_dispatch(#dispatch{path=Path}, Context) ->
    case m_alternative_uris:get_dispatch(Path, Context) of
        {RscId,IsPermanent} -> {ok, #dispatch_redirect{location=m_rsc:p(RscId, page_url, Context), is_permanent=IsPermanent}};
        undefined -> undefined
    end.

%% @doc Merge the alternative uri fields when merging resources
observe_rsc_merge(#rsc_merge{ winner_id = WinnerId, looser_id = LoserId }, Context) ->
    W = m_rsc:p(WinnerId, alternative_uris, Context),
    L = m_rsc:p(LoserId, alternative_uris, Context),
    case {W, L} of
        {undefined, _} -> ok;
        {_, undefined} -> ok;
        _ ->
            case z_string:trim(<<W/binary, $\n, L/binary>>) of
                <<>> -> ok;
                W -> ok;
                W1 ->
                    {ok, _} = m_rsc:update(WinnerId, [ {alternative_uris, W1} ], [ no_touch ], Context),
                    ok
            end
    end.

manage_schema(_, Context) ->
    m_alternative_uris:install(Context).

select_best([], _BestSize, {_Path, RscId, IsPerm}) ->
    {ok, {RscId, IsPerm}};
select_best([{Path, _, _}=New|Rest], BestSize, Best) ->
    PathSize = size(Path),
    case PathSize > BestSize of
        true -> select_best(Rest, Path, New);
        false -> select_best(Rest, BestSize, Best)
    end.
