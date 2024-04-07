function [after_seq] = normalize_sample_2d(before_seq)

% before_seq = max(before_seq, 0);
after_seq = before_seq - min(min(before_seq));
after_seq = after_seq/max(max(after_seq));

end

