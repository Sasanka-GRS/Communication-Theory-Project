%---------------------------UPLINK CHANNEL---------------------------------
n_up = 5; %Number of users
k_up = [10 12 14 16 18];%Length of transmission window for each user
dest = [1 2 3 4 5];%Destination node number of each transmitter node
freq = [30 40 50 60 70];%Modulating frequencies
freqc = [300 600 900 12000 15000];%Carrier frequencies
t = 0:1/(10*max(freq)):max(k_up)-1/(10*max(freq));%Time scale
l = size(t);
l = l(2);
t = t';
m = 10*max(freq);%Upscaling factor
dev = 50;%Frequency deviation
k_size = size(k_up);
info_up = zeros(max(k_up),n_up);
info_up_upscaled = zeros(l,n_up);
modulated = zeros(l,n_up);

%Generate Message bits
for ii = 1:n_up
    info_up(1:k_up(1,ii),ii) = bpskmap(floor(rand(k_up(1,ii),1)*2));
    info_up(1,ii) = 0;
end

%Upscaling
for ii = 1:n_up
    info_up_upscaled(1:m:l,ii) = info_up(:,ii);
end

%FM signalling
for ii = 1:n_up
    modulated(:,ii) = fmmod(info_up_upscaled(:,ii),freqc(1,ii),10*freqc(1,ii),dev);
end

%---------------------------DOWNLINK CHANNEL---------------------------------
%Transmission at Central node
time = 1000;%Number of time durations for which the simulation runs
for ii = 1:time
    if modulated == 0
        x1 = ii;
        pause(0.5);
        message = ['Sending stopped at time ', num2str(x1), ' sec'];
        disp(message);
        break;
    end
    x = ceil(rand()*n_up);%Present node whose signal is being sent
    demodulated = zeros(l,1);
    demodulated_down = zeros(l,1);
    if modulated(:,x) ~= 0
        destination = dest(1,x);%Destination of the information packets
        message = ['Sending ', num2str(k_up(1,x)), ' packets from input node ',  num2str(x), ' to output node ',  num2str(destination)];
        disp(message);
        demodulated(:,1) = fmdemod(modulated(:,x),freqc(1,x),10*freqc(1,x),dev);%FM demodulation at central node
        downscaled = demodulated(1:m:l,1);%Downscaling from time factor
     
        guess_centralNode(:,1) = sign(downscaled(:,1));%Guessing out the noise
        %------------------Information as received at central Node--------
        guess_centralNode1 = guess_centralNode(1:k_up(1,x));%Removing trailing 0s (if any)
        
        %Demodulation and reconstruction at Central node is done, now
        %transmission to destination node
        info_down_upscaled = zeros(l,1);
        modulating_down = zeros(l,1);
        modulated_down = zeros(l,1);
        guess_centralNode2 = zeros(max(k_up),1);
        guess_centralNode2(1:k_up(1,x),1) = guess_centralNode1(:,1);
        info_down_upscaled(1:m:l,1) = guess_centralNode2(:,1);%Upscaling
        modulating_down(:,1) = info_down_upscaled(:,1);%Message signal
        modulated_down(:,1) = fmmod(modulating_down(:,1),freqc(1,x),10*freqc(1,x),dev);%FM signal
        
        demodulated_down(:,1) = fmdemod(modulated_down(:,1),freqc(1,x),10*freqc(1,x),dev);%FM demodulation at central node
        downscaled_down = demodulated_down(1:m:l,1);%Downscaling from time factor
        guess_outputNode(:,1) = sign(downscaled_down(:,1));%Guessing out the noise
        %------------------Information as received at output Node---------
        guess_outputNode1 = guess_outputNode(1:k_up(1,x));%Removing trailing 0s (if any)

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
        stem(guess_centralNode1(:,1),'.','red');
        xlabel("n");
        ylabel("c[n]");
        title("Information packet at Central Node");
        ylim([-1.5 1.5]);
        subplot(3,1,3);
        stem(guess_outputNode1(:,1),'.','black');
        xlabel("n");
        ylabel("y[n]");
        title("Information packet at Output (Receiver Node)");
        ylim([-1.5 1.5]);
        modulated(:,x) = zeros(l,1);
    end
end
