function imag = traj2img(traj, thk) 

thickness = thk;

traj_x = round(traj(:,1));
traj_y = round(traj(:,2));

col_min = min(traj_x);
col_max = max(traj_x);
row_min = min(traj_y);
row_max = max(traj_y);

scale = max(col_max - col_min, row_max - row_min);
thickness = round(thickness * scale / 100);

% for i = 1:length(traj_x)-1
%     vel(i) = norm([traj_x(i+1)-traj_x(i) traj_y(i+1)-traj_y(i)],2);
% end

% vel = movmean(vel, thickness);
% vel = vel./max(vel);
num_col = col_max - col_min + 1 + thickness*2;
traj_x = traj_x - col_min + 1 + thickness;
num_row = row_max - row_min + 1 + thickness*2;
traj_y = traj_y - row_min + 1 + thickness;
scale = max(num_row, num_col);
imag = zeros(num_row, num_col);
for i = 1:length(traj_x)-1 
    row = traj_y(i);
    col = traj_x(i);
    imag(row, col) =  1;
    thk = thickness;  
%     thk = round(thickness/exp(vel(i)));
    for ii = -1*thk:thk
        for jj = -1*thk:thk
            r = row + ii;
            c = col + jj;
            imag(r,c) = 1;
        end
    end
end

imag = flip(imag);
end
