function [DGIST_entities, DGIST_isOffloading] = DGIST_getOffloadingDecision_with_cloud(HBNU_prev_timeslot_capacity, t, simParams, DGIST_entities)

num_of_egos = length(DGIST_entities.trucks);
arrivals = [];
offloads = [];
if simParams.V2V_type == 0
    %% Set RSU association
    for i = 1:num_of_egos
        associated_RSU_id = simParams.targetRsuID(i);
        % DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
        % associated_RSU_id = 9;          % Temporal...
        DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
    end
    
    for j = 1:simParams.numOfRSU
        for i = 1:num_of_egos
            associated_RSU_idx = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
            DGIST_entities.rsus(j).rsu.associated_trucks(t, i) = associated_RSU_idx;
        end
    end
    
    %% Make decisions on offloading
    for i = 1:num_of_egos
        arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
        while arrival < 0
            arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
        end
        arrivals = [arrivals, arrival];
    
        if t == 1
            offload = simParams.offloadBytesSize * 8;
            DGIST_entities.trucks(i).truck.prev_possible_capacity(t, 1) = 1;
        else
            offload = simParams.offloadBytesSize * 8 * DGIST_entities.trucks(i).truck.prev_possible_capacity(t - 1, 1);
        end
        offloads = [offloads, offload];
    
        DGIST_entities.trucks(i).truck.arrival(t, 1) = arrival;
        DGIST_entities.trucks(i).truck.offload(t, 1) = offload;
        
        idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
        i_truck_q = DGIST_entities.trucks(i).truck.processing_queue(t, 1);
        j_rsu_q = DGIST_entities.rsus(idx_of_associated_rsu).rsu.processing_queue(t, 1);
        cloud_q = DGIST_entities.cloud.processing_queue(t, 1);
    
        %% Algorithm %%% with CLOUD
        % Case 1  % OBU에서 처리하는 경우
        min_fun = @(x) simParams.V * (simParams.alpha * x^3 + simParams.beta) - (x / simParams.gamma - arrivals(i)) * i_truck_q;
        if i==1 || i==3
            selected_frequency = fminbnd(min_fun, simParams.min_S_high, simParams.max_S_high);
            solution_case1 = min_fun(selected_frequency);
        elseif i==2 || i==4
            selected_frequency = fminbnd(min_fun, simParams.min_S_low, simParams.max_S_low);
            solution_case1 = min_fun(selected_frequency);
        end
    
        % Case 2  % rsu에서 처리하는 경우
        solution_case2 = 0.7*simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * j_rsu_q;
    
        % Case 3  % cloud에서 처리하는 경우 
        solution_case3 = 0.7*simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * cloud_q;
    
        %% Find the best solution
        solutions = [solution_case1, solution_case2, solution_case3];
        idx_of_solution = find(solutions == min(solutions));
    
        switch idx_of_solution(1)
            case 1
                % Local processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = selected_frequency;
            case 2
                % RSU processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 1;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
            case 3
                % Cloud processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 1;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
        end
    end
    
    DGIST_isOffloading = zeros(1, num_of_egos);
    for i = 1:num_of_egos
        idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
        if DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) == 1
            DGIST_isOffloading(i) = 1;
        else
            DGIST_isOffloading(i) = 0;
        end
    end
elseif simParams.V2V_type == 1
    %% Set RSU association
    for i = 1:num_of_egos
        associated_RSU_id = simParams.targetRsuID(i);
        % DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
        % associated_RSU_id = 9;          % Temporal...
        DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
    end
    
    for j = 1:simParams.numOfRSU
        for i = 1:num_of_egos
            associated_RSU_idx = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
            DGIST_entities.rsus(j).rsu.associated_trucks(t, i) = associated_RSU_idx;
        end
    end
    
    %% Make decisions on offloading
    for i = 1:num_of_egos
        arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
        while arrival < 0
            arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
        end
        arrivals = [arrivals, arrival];
    
        if t == 1
            offload = simParams.offloadBytesSize * 8;
            DGIST_entities.trucks(i).truck.prev_possible_capacity(t, 1) = 1;
        else
            offload = simParams.offloadBytesSize * 8 * DGIST_entities.trucks(i).truck.prev_possible_capacity(t - 1, 1);
        end
        offloads = [offloads, offload];
    
        DGIST_entities.trucks(i).truck.arrival(t, 1) = arrival;
        DGIST_entities.trucks(i).truck.offload(t, 1) = offload;
        
        idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
        i_truck_q = DGIST_entities.trucks(i).truck.processing_queue(t, 1);
        j_rsu_q = DGIST_entities.rsus(idx_of_associated_rsu).rsu.processing_queue(t, 1);
        cloud_q = DGIST_entities.cloud.processing_queue(t, 1);
        %% Algorithm %%% with CLOUD & other vehicles
        % Case 1  % OBU에서 처리하는 경우
        min_fun = @(x) simParams.V * (simParams.alpha * x^3 + simParams.beta) - (x / simParams.gamma - arrivals(i)) * i_truck_q;
        if i==1 || i==3
            selected_frequency = fminbnd(min_fun, simParams.min_S_high, simParams.max_S_high);
            solution_case1 = min_fun(selected_frequency);
        elseif i==2 || i==4
            selected_frequency = fminbnd(min_fun, simParams.min_S_low, simParams.max_S_low);
            solution_case1 = min_fun(selected_frequency);
        end
    
        % Case 2  % rsu에서 처리하는 경우
        solution_case2 = 0.7*simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * j_rsu_q;
    
        % Case 3  % cloud에서 처리하는 경우 
        solution_case3 = 0.7*simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * cloud_q;
    
        % Case 4  % other vehicle에서 처리하는 경우
        solution_case4_list = zeros(1,4); % 오프로딩 받을 vehicle 계산 위해서
        for j = 1:num_of_egos
            j_truck_q = DGIST_entities.trucks(j).truck.processing_queue(t, 1);
            if i == j
                solution_case4_list(j) = inf;
                continue;
            end
            solution_case4_list(j) = 0.5*simParams.V*simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + 0.5*offloads(i) * j_truck_q;
        end
        DGIST_entities.trucks(i).truck.offload_decision_to_vehicle(t,1) = find(solution_case4_list == min(solution_case4_list),1);
        solution_case4 = min(solution_case4_list);
    
        %% Find the best solution
        solutions = [solution_case1, solution_case2, solution_case3, solution_case4];
        idx_of_solution = find(solutions == min(solutions));
    
        switch idx_of_solution(1)
            case 1
                % Local processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = selected_frequency;
                DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
            case 2
                % RSU processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 1;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
            case 3
                % Cloud processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 1;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
            case 4
                % V2V processing
                DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
                DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
                DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 1;
        end
    end
    
    DGIST_isOffloading = zeros(1, num_of_egos);
    for i = 1:num_of_egos
        idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
        if DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) == 1
            DGIST_isOffloading(i) = 1;
        else
            DGIST_isOffloading(i) = 0;
        end
    end
end
% %% Set RSU association
% for i = 1:num_of_egos
%     associated_RSU_id = simParams.targetRsuID(i);
%     % DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
%     % associated_RSU_id = 9;          % Temporal...
%     DGIST_entities.trucks(i).truck.associatedRSU(t, 1) = find(simParams.idRSUs == associated_RSU_id);
% end
% 
% for j = 1:simParams.numOfRSU
%     for i = 1:num_of_egos
%         associated_RSU_idx = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
%         DGIST_entities.rsus(j).rsu.associated_trucks(t, i) = associated_RSU_idx;
%     end
% end
% 
% %% Make decisions on offloading
% for i = 1:num_of_egos
%     arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
%     while arrival < 0
%         arrival = normrnd(simParams.avg_arrival, simParams.std_arrival);
%     end
%     arrivals = [arrivals, arrival];
% 
%     if t == 1
%         offload = simParams.offloadBytesSize * 8;
%         DGIST_entities.trucks(i).truck.prev_possible_capacity(t, 1) = 1;
%     else
%         offload = simParams.offloadBytesSize * 8 * DGIST_entities.trucks(i).truck.prev_possible_capacity(t - 1, 1);
%     end
%     offloads = [offloads, offload];
% 
%     DGIST_entities.trucks(i).truck.arrival(t, 1) = arrival;
%     DGIST_entities.trucks(i).truck.offload(t, 1) = offload;
% 
%     idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
%     i_truck_q = DGIST_entities.trucks(i).truck.processing_queue(t, 1);
%     j_rsu_q = DGIST_entities.rsus(idx_of_associated_rsu).rsu.processing_queue(t, 1);
%     cloud_q = DGIST_entities.cloud.processing_queue(t, 1);
% 
%     %% Algorithm %%% with CLOUD
%     % Case 1  % OBU에서 처리하는 경우
%     min_fun = @(x) simParams.V * (simParams.alpha * x^3 + simParams.beta) - (x / simParams.gamma - arrivals(i)) * i_truck_q;
%     if i==1 || i==3
%         selected_frequency = fminbnd(min_fun, simParams.min_S_high, simParams.max_S_high);
%         solution_case1 = min_fun(selected_frequency);
%     elseif i==2 || i==4
%         selected_frequency = fminbnd(min_fun, simParams.min_S_low, simParams.max_S_low);
%         solution_case1 = min_fun(selected_frequency);
%     end
% 
%     % Case 2  % rsu에서 처리하는 경우
%     solution_case2 = simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * j_rsu_q;
% 
%     % Case 3  % cloud에서 처리하는 경우 
%     solution_case3 = simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * cloud_q;
% 
%     %% Find the best solution
%     solutions = [solution_case1, solution_case2, solution_case3];
%     idx_of_solution = find(solutions == min(solutions));
% 
%     switch idx_of_solution(1)
%         case 1
%             % Local processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = selected_frequency;
%         case 2
%             % RSU processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 1;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
%         case 3
%             % Cloud processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 1;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
%     end
% end
% 
% DGIST_isOffloading = zeros(1, num_of_egos);
% for i = 1:num_of_egos
%     idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
%     if DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) == 1
%         DGIST_isOffloading(i) = 1;
%     else
%         DGIST_isOffloading(i) = 0;
%     end
% end

% %% Algorithm %%% with CLOUD & other vehicles
%     % Case 1  % OBU에서 처리하는 경우
%     min_fun = @(x) simParams.V * (simParams.alpha * x^3 + simParams.beta) - (x / simParams.gamma - arrivals(i)) * i_truck_q;

%     if i==1 || i==3
%         selected_frequency = fminbnd(min_fun, simParams.min_S_high, simParams.max_S_high);
%         solution_case1 = min_fun(selected_frequency);
%     elseif i==2 || i==4
%         selected_frequency = fminbnd(min_fun, simParams.min_S_low, simParams.max_S_low);
%         solution_case1 = min_fun(selected_frequency);
%     end
% 
%     % Case 2  % rsu에서 처리하는 경우
%     solution_case2 = simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * j_rsu_q;
% 
%     % Case 3  % cloud에서 처리하는 경우 
%     solution_case3 = simParams.V * simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * cloud_q;
% 
%     % Case 4  % other vehicle에서 처리하는 경우
%     solution_case4_list = zeros(1,4); % 오프로딩 받을 vehicle 계산 위해서
%     for j = 1:num_of_egos
%         j_truck_q = DGIST_entities.trucks(j).truck.processing_queue(t, 1);
%         if i == j
%             solution_case4_list(j) = inf;
%             continue;
%         end
%         solution_case4_list(j) = 0.5*simParams.V*simParams.network_power - (offloads(i) - arrivals(i)) * i_truck_q + offloads(i) * j_truck_q;
%     end
%     DGIST_entities.trucks(i).truck.offload_decision_to_vehicle(t,1) = find(solution_case4_list == min(solution_case4_list),1);
%     solution_case4 = min(solution_case4_list);
% 
%     %% Find the best solution
%     solutions = [solution_case1, solution_case2, solution_case3, solution_case4];
%     idx_of_solution = find(solutions == min(solutions));
% 
%     switch idx_of_solution(1)
%         case 1
%             % Local processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = selected_frequency;
%             DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
%         case 2
%             % RSU processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 1;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
%         case 3
%             % Cloud processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 1;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 0;
%         case 4
%             % V2V processing
%             DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.selected_frequency(t, 1) = 0;
%             DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) = 1;
%     end
% end
% 
% DGIST_isOffloading = zeros(1, num_of_egos);
% for i = 1:num_of_egos
%     idx_of_associated_rsu = DGIST_entities.trucks(i).truck.associatedRSU(t, 1);
%     if DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, idx_of_associated_rsu) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1) == 1 || DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1) == 1
%         DGIST_isOffloading(i) = 1;
%     else
%         DGIST_isOffloading(i) = 0;
%     end
% end