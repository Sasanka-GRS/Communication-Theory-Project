%---------------------------UPLINK CHANNEL---------------------------------
n_up = 5; %Number of users
k_up = [10 12 14 16 18];%Length of transmission window for each user
dest = [1 2 3 4 5];%Destination node number of each transmitter node
freq = [300 400 500 600 700];%Modulating frequencies
t = 0:1/(10*max(freq)):max(k_up)-1/(10*max(freq));%Time scale
l = size(t);
l = l(2);
t = t';
m = 10*max(freq);%Upscaling factor
k_size = size(k_up);
info_up = zeros(max(k_up),n_up);
info_up_upscaled = zeros(l,n_up);

%Generate Message bits
for ii = 1:n_up
    info_up(1:k_up(1,ii),ii) = bpskmap(floor(rand(k_up(1,ii),1)*2));
end

%Upscaling
for ii = 1:n_up
    info_up_upscaled(1:m:l,ii) = info_up(:,ii);
end

a = 0.5;
length = 10;% (truncated outside [-length*T,length*T])
%raised cosine transmit filter (time vector set to a dummy variable which is not used)
[transmit_filter,dummy] = raised_cosine(a,m,length);
receive_filter = fliplr(conj(transmit_filter));%Matched filter of Transmit filter (Received filter)
l2 = size(transmit_filter);
l1 = l2(1)+l-1;
tx_output = zeros(l1,n_up);
noisy = zeros(l1,n_up);
rx_output = zeros(l1+l2(1)-1,n_up);
Centralnode_signal = zeros(max(k_up),n_up);

stddev_up = 0.3;%Standard deviation of AWGN in uplink channel

for ii = 1:n_up
    tx_output(:,ii) = conv(info_up_upscaled(:,ii),transmit_filter);
    noisy(:,ii) = stddev_up*randn(l1,1)+tx_output(:,ii);
    rx_output(:,ii) = conv(noisy(:,ii),receive_filter);
    rx_output1 = rx_output(1:m:l1+l2(1)-1,ii)/m;%Down sampling
    Centralnode_signal(1:k_up(1,ii),ii) = rx_output1(21:20+k_up(1,ii));
end

Centralnode_signal = sign(Centralnode_signal);

stddev_down = 0.3;%Standard deviation of AWGN in downlink channel

%---------------------------DOWNLINK CHANNEL---------------------------------
time = 20;%Number of time durations for which the simulation runs
for ii = 1:time
    if Centralnode_signal == 0
        x1 = ii;
        pause(0.5);
        message = ['Sending stopped at time ', num2str(x1), ' sec'];
        disp(message);
        break;
    end
    x = ceil(rand(1,1)*n_up);%Present node whose signal is being sent
    info_down_upscaled = zeros(l,1);
    if Centralnode_signal(1,x) ~= 0
        destination = dest(1,x);%Destination of the information packets
        message = ['Sending ', num2str(k_up(1,x)), ' packets from input node ',  num2str(x), ' to output node ',  num2str(destination)];
        disp(message);

        %Upscaling
        info_down_upscaled(1:m:l,1) = Centralnode_signal(:,x);

        a = 0.5;
        length = 10;% (truncated outside [-length*T,length*T])
        %raised cosine transmit filter (time vector set to a dummy variable which is not used)
        [transmit_filter,dummy] = raised_cosine(a,m,length);
        receive_filter = fliplr(conj(transmit_filter));%Matched filter of Transmit filter (Received filter)
        l2 = size(transmit_filter);
        l1 = l2(1)+l-1;
        Outputnode_signal = zeros(max(k_up),n_up);

        tx_output = conv(info_down_upscaled(:,1),transmit_filter);
        noisy = stddev_down*randn(l1,1)+tx_output;
        rx_output = conv(noisy,receive_filter);
        rx_output1 = rx_output(1:m:l1+l2(1)-1,1)/m;%Down sampling
        Outputnode_signal(1:k_up(1,x),1) = rx_output1(21:20+k_up(1,x));
        Outputnode_signal = sign(Outputnode_signal);
        
        pause(1);
        message = ['Received ', num2str(k_up(1,x)), ' packets from input node ',  num2str(x), ' at output node ',  num2str(destination)];
        disp(message);
        pause(1);
        
        figure();
        subplot(3,1,1);
        stem(info_up(1:k_up(1,x),x),'.');
        xlabel("n");
        ylabel("x[n]");
        title("Information packet at Input (Transmitter Node)");
        ylim([-1.5 1.5]);
        subplot(3,1,2);
        stem(Centralnode_signal(1:k_up(1,x),x),'.','red');
        xlabel("n");
        ylabel("c[n]");
        title("Information packet at Central Node");
        ylim([-1.5 1.5]);
        subplot(3,1,3);
        stem(Outputnode_signal(1:k_up(1,x),1),'.','black');
        xlabel("n");
        ylabel("y[n]");
        title("Information packet at Output (Receiver Node)");
        ylim([-1.5 1.5]);
        Centralnode_signal(:,x) = zeros(max(k_up),1);
    end
end
