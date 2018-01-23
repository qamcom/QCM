% Find cheapest tree given path and node costs
%
% [prev,next,dist,node,path,routing]=dijkstra(graph,node,source)
%
% https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
%
% -------------------------------------------------------------------------
%     This is a part of the Qamcom Channel Model (QCM)
%     Copyright (C) 2017  Björn Sihlbom, QAMCOM Research & Technology AB
%     mailto:bjorn.sihlbom@qamcom.se, http://www.qamcom.se, https://github.com/qamcom/QCM 
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

function [prev,next,dist,node,path,routing]=dijkstra(graphcost,nodecost,sources)

graphcost(isinf(graphcost))=0; % Disable infinitely costly paths

N = size(graphcost,1);

% Find complete tree per source
for kk=1:numel(sources)
    source = sources(kk);
    
    %  2
    %  3      create vertex set Q
    %  4
    %  5      for each vertex v in Graph:             // Initialization
    %  6          dist[v] = INFINITY                  // Unknown distance from source to v
    %  7          prev[v] = UNDEFINED                 // Previous node in optimal path from source
    %  8          add v to Q                          // All nodes initially in Q (unvisited nodes)
    distkk    = inf(N,1);
    prevkk    = nan(N,1);
    nextkk    = nan(N,1);
    
    Q    = 1:N;
    
    %  9
    % 10      dist[source] = 0                        // Distance from source to source
    distkk(source) = 0;
    
    % 11
    % 12      while Q is not empty:
    % 13          u = vertex in Q with min dist[u]    // Source node will be selected first
    % 14          remove u from Q
    while ~isempty(Q)
        [~, uq] = min(distkk(Q));
        u = Q(uq);
        Q = setdiff(Q,u);
        
        % 15
        % 16          for each neighbor v of u:           // where v is still in Q.
        % 17              alt = dist[u] + length(u, v)
        for v = Q % v has not been traced yet (unvisited)
            if graphcost(u,v) % u and v are neighbors
                alt = distkk(u)+graphcost(u,v)+nodecost(v);
                
                % 18              if alt < dist[v]:       // A shorter path to v has been found
                % 19                  dist[v] = alt
                % 20                  prev[v] = u
                if alt < distkk(v),
                    distkk(v)=alt;
                    prevkk(v)=u;
                    nextkk(u)=v;
                end % if alt < dist(v)
                
            end % if graph(u,v)
        end % for v = Q
    end % while ~isempty(Q)
    
    % 21
    % 22      return dist[], prev[]
    
    % Choose routes/source with lowest cost
    % I.e. each node will be routed to the GW providing lowest routing cost 
    if kk==1
        dist    = distkk;
        prev    = prevkk;
        next    = nextkk;
    else
        for n=1:N
            if distkk(n)<dist(n)
                dist(n) = distkk(n);
                prev(n) = prevkk(n);
                next(n) = nextkk(n);
            end
        end
    end
    
end

% ---------------------------------------------------
% Get meta data (Routing table, Route and Node usage)
node    = zeros(N,1);
path    = zeros(N);
routing = nan(N);
for n=1:N % For each node
    
    % Path to previous node
    nextn = n;
    prevn = prev(n);
    
    % And trace entire path and count nrof use of nodes and paths
    routing(n,source)=prevn;
    while ~isnan(prevn)
        routing(prevn,n)  = nextn;
        path(prevn,nextn) = path(prevn,nextn)+1;
        path(nextn,prevn) = path(nextn,prevn)+1;
        node(prevn)       = node(prevn )+1;
        nextn             = prevn;
        prevn             = prev(prevn);
    end
    
end
