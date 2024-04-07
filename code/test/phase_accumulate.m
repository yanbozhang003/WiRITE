function output = phase_accumulate(x,y,sample)
    sample_len = length(sample);
    
    output = 0;
    static = complex(x,y);
    dynamic = sample - static;
    for i = 1:1:(sample_len-1)
        ii = i+1;
        
%         phase_diff = abs(angle(sample(ii)-static)-angle(sample(i)-static));
%         output = output+phase_diff;
        
        dynamic_angle = exp(1i*angle(dynamic));
        output = output + abs(angle(dynamic_angle(ii)/dynamic_angle(i)));
    end
end

