function [DGIST_entities, DGIST_processing_queue_backlog] = DGIST_UpdateQueue(HBNU_current_timeslot_capacity, t, simParams, DGIST_entities, notification_trigger)

%% Queue update
num_of_egos = length(DGIST_entities.trucks);

% Truck queue update
for i = 1:num_of_egos
    i_truck_arrival = DGIST_entities.trucks(i).truck.arrival(t, 1);
    i_truck_offload = DGIST_entities.trucks(i).truck.offload(t, 1);

    i_truck_s = DGIST_entities.trucks(i).truck.selected_frequency(t, 1);
    associated_rsu_idx = DGIST_entities.trucks(i).truck.associatedRSU(t);

    i_truck_q = DGIST_entities.trucks(i).truck.processing_queue(t, 1);
    i_truck_theta = DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, associated_rsu_idx);
    i_truck_sigma = DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1);
    i_truck_myu = DGIST_entities.trucks(i).truck.offload_decision_to_V2V(t,1);

    input = i_truck_arrival;
    output = (i_truck_s / simParams.gamma) * (1 - i_truck_theta - i_truck_sigma) + i_truck_offload * i_truck_theta + i_truck_offload * i_truck_sigma + i_truck_offload * i_truck_myu;

    DGIST_entities.trucks(i).truck.processing_queue(t + 1, 1) = max(0, ...
    DGIST_entities.trucks(i).truck.processing_queue(t, 1) + input - output);  
    % DGIST_entities.trucks(i).truck.processing_queue(t + 1, 1) = 3*10^4;

    % Previous_PDR update
    DGIST_entities.trucks(i).truck.prev_possible_capacity(t, 1) = HBNU_current_timeslot_capacity(i);
end

% RSU queue update
for j = 1:simParams.numOfRSU
    j_rsu_q = DGIST_entities.rsus(j).rsu.processing_queue(t, 1);
    
    % FOR RSU CONTROL
%     requests_from_truck = 0;
%     for i = 1:simParams.platoonNvehicles - 1
%         if notification_trigger(i, j) == 1
%             requests_from_truck = requests_from_truck + 1;
%         end
%     end
%     extra_arrival = simParams.RSU_extra_arrival * requests_from_truck;
    extra_arrival = 0;

    associated_truck_idxs = [find(DGIST_entities.rsus(j).rsu.associated_trucks(t, :) == j)];
    q_input = 0;

    for i = associated_truck_idxs
        i_truck_offload = DGIST_entities.trucks(i).truck.offload(t, 1);
        associated_rsu_idx = DGIST_entities.trucks(i).truck.associatedRSU(t);
        i_truck_theta = DGIST_entities.trucks(i).truck.offload_decision_to_RSU(t, associated_rsu_idx);

        q_input = q_input + i_truck_offload * i_truck_theta;
    end

    DGIST_entities.rsus(j).rsu.processing_queue(t + 1, 1) = max(0, ...
        j_rsu_q + q_input - simParams.fixed_rsu_work) + 3600 * 0.05;
end

% Cloud queue update
q_input = 0;
for i = 1:num_of_egos
    i_truck_sigma = DGIST_entities.trucks(i).truck.offload_decision_to_cloud(t, 1);
    i_truck_offload = DGIST_entities.trucks(i).truck.offload(t, 1);

    q_input = q_input + i_truck_sigma * i_truck_offload;
end

DGIST_entities.cloud.processing_queue(t + 1, 1) = max(0, ...
    DGIST_entities.cloud.processing_queue(t, 1) + q_input - simParams.fixed_cloud_work) + 3600 * 0.2;

%% Return
DGIST_processing_queue_backlog = zeros(1, num_of_egos);
for i = 1:num_of_egos
    DGIST_processing_queue_backlog(i) = DGIST_entities.trucks(i).truck.processing_queue(t + 1, 1);
end


