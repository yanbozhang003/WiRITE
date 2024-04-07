function [c, r, end_idx, loss, f] = f_est(bb) 

lambda = 5.8;
amp_th = 0.05;
end_idx(1) = 2;
amp = inf(1,length(bb));
f = inf(1,length(bb));
r = inf(1,length(bb));
c = inf(length(bb),2);
n_p = zeros(1,length(bb)) + 100;
loss = zeros(1,length(bb)) + 100;

% seperate a sample (bb) to several windows (i,ii)
% each window contails CSI phases locate on one circle, thus corresponding
% to hand moving in a straight line.
% Question:
% 1) If mean(n_tmp) >= 0.04, why still increase window size?
% 2) line 25: is that necessary for the dynamic component phase ranging for
% each window larger than pi? 
for i = 1:(length(bb) - 20)
    i
    fit_success = 0;
    for ii = i+20:2:min(i+200,length(bb))
        amp_diff = abs(bb(ii) - bb(i));  
        % center [x_tmp, y_tmp], radius r_tmp, normalized noise n_tmp
        [x_tmp y_tmp r_tmp n_tmp] = circfit_2(bb(i:ii));
%         phase_accumulate = phase_diff_sum(bb(i:ii) - complex(x_tmp,y_tmp));
%         angle = 360*phase_accumulate/(2*pi);
%         
%         x = real(bb(i:ii)); y = imag(bb(i:ii));
%         plot(x,y,'k.');hold on
%         plot(x_tmp, y_tmp,'ro');hold off
%         title(['phase accumulate: ', num2str(angle)]);
%         waitforbuttonpress();
        
        if r_tmp > amp_th % ?
            if mean(n_tmp) < 0.04  % fSNR threshold = 0.04
                if phase_diff_sum(bb(i:ii) - complex(x_tmp,y_tmp)) > pi
                    fit_success = 1;
                    break;
                end
            end
        end
    end
%       
    if fit_success == 0
        end_idx(i) = inf;
        
        if i > 1 && c(i-1,1) ~= inf 
            c(i,1) = c(i-1,1);
            c(i,2) = c(i-1,2);
        
%             if f(i) == inf 
%                 f(i) = exp(1i*angle(bb(i)-complex(c(i-1,1),c(i-1,2))));
%             end
        end
        continue
        
    else
        end_idx(i) = ii;
        [c(i,1), c(i,2), r(i), n] = circfit_2(bb(i:ii));
%         loss(i) = mean(n);
%         f_tmp = exp(1i*angle(bb(i:ii)-complex(c(i,1),c(i,2))));
    end
%     for idx = i:ii
%         if f(idx) == inf
%             f(idx) = f_tmp(idx-i+1);
%             continue;
%         end
%         if mean(n) < n_p(idx)
%             f(idx) = f_tmp(idx-i+1);
%             n_p(idx) = mean(n);
%         end

%     end
end

for ci = 1:length(bb)
    if c(ci,1) == inf
        for cii = ci+1:length(bb)
            if c(cii,1) ~= inf
                c(ci,1) = c(cii,1);
                c(ci,2) = c(cii,2);
                break;
            end
        end
    end
end

% circle center moving average over 20 concecutive circles,why?
c(:,1) = movmean(c(:,1), 20);
c(:,2) = movmean(c(:,2), 20);

% extract the dynamic component phase for each CSI
for fi = 1:length(bb)
    if f(fi) == inf
        f(fi) = exp(1i*angle(bb(fi)-complex(c(fi,1),c(fi,2))));
    end
end
                

end

function output = phase_diff_sum(input)
    f = exp(1i*angle(input));
    output = 0;
    for i = 1:length(input)-1
        output = output + abs(angle(f(i+1)/f(i)));
    end
            
%     for i = 1:length(f_input)
%         tmp(i) = abs(angle(f_input(i)/f_input(1)));
%     end
%     output = max(tmp);
end
