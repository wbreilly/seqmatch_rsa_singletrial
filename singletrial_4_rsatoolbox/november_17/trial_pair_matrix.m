betas = betas.identifier;


pairs = cell(900,900);
for val1 = 1:900
    for val2 = 1:900
        pairs(val2,val1) = {[betas(val1,:), ' ', betas(val2,:)]};
    end
end

betas(:).identifier

%% full trial pair matrix
pairs = cell(900,900);
for val1 = 1:900
    for val2 = 1:900
        pairs(val2,val1) = {[betas(val1).identifier, ' ', betas(val2).identifier]};
    end
end

%%


SC_trials = [];
start_val = 1081:3240:16200;
for ival = 1:length(start_val) 
    SC_trials = [SC_trials mask1_trials(start_val(ival):start_val(ival)+1079)];
end

SC_trials2 = [];
start_val = 361:1080:5400;
for ival = 1:length(start_val) 
    SC_trials2 = [SC_trials2 mask2_trials(start_val(ival):start_val(ival)+359)];
end

SI_trials3 = [];
            start_val = 1441:2160:10800;
            for ival = 1:length(start_val) 
                SI_trials3 = [SI_trials3 mask3_trials(start_val(ival):start_val(ival)+719)];
            end