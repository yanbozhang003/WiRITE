function [int_x, int_y] = find_traj(a_left, a_right, f_left, f_right)
c = 4; 
int_x = [];
int_y = [];
cent_left = [0 0];
cent_right = [41 0];
lambda = 5.8;
f_left_last = f_left(1);
f_right_last = f_right(1);
pl_left = a_left * 2;
pl_right = a_right * 2;
   
for f_idx = 1:length(f_left)
   if f_left(f_idx) ~= inf && f_right(f_idx) ~= inf
        f_left_delta = angle(f_left(f_idx)/f_left_last);
        f_right_delta = angle(f_right(f_idx)/f_right_last);
% skip abnormal phase delta        
        if abs(f_left_delta) > 1
            f_left_delta = 0;
        end
        if abs(f_right_delta) > 1
            f_right_delta = 0;
        end
%         
        pl_left = pl_left - lambda * f_left_delta/(2*pi);
        pl_right = pl_right - lambda * f_right_delta/(2*pi);
        a_left = pl_left/2;
        a_right = pl_right/2;
        if a_left < 4 || a_right < 4
            break;
        end
        b_left = sqrt(a_left^2 - c^2);
        b_right = sqrt(a_right^2 - c^2);
        
        [xx yy] = circcirc(cent_left(1), cent_left(2), b_left, cent_right(1), cent_right(2), b_right);
        
        

        if isnan(xx(1)) == 0
            int_x = [int_x; xx(1)];
            int_y = [int_y; yy(1)];
            f_left_last = f_left(f_idx);
            f_right_last = f_right(f_idx);
            
        else
            int_x = [];
            int_y = [];
            break;
        end
   
   end
   
   int_x = movmean(int_x, 5);
   int_y = movmean(int_y, 5);


end
