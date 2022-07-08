function y =  bpskmap(a)
    y = zeros(length(a),1);
    for ii = 1:length(a)
        if a(ii) == 0
            y(ii,1) = -1;
        else
            y(ii,1) = 1;
        end
    end
end