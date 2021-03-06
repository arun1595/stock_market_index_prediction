function featureVector = computeFeatures(data, days)


  closing_prices = data(:,1);
  high_prices = data(:,3);
  low_prices = data(:,4);

  sz = size(closing_prices);

  %  ***********************************************
  %   1. Code for computing Simple Moving Average
  %
  %
  %Find the simple moving average from the closing prices
  
  simple_mov_avg = zeros(size(closing_prices));

  % Skip the last 9 rows because we can't compute simple moving average
  for i=1:size(simple_mov_avg,1)-9
	simple_mov_avg(i) = mean(closing_prices(i:i+ days - 1));
  end
  %fprintf("Size of simple moving average is:")
  size(simple_mov_avg);
  fprintf("\nComputed simple moving average");
  %  ***********************************************
  %   2. Code for computing Exponential Moving Average
  %
  %

  exp_mov_avg = expMovAvg(data, days);
  exp_mov_avg(isnan(exp_mov_avg))=0;
  fprintf("\nComputed exponential moving average");
  %featureVector = [simple_mov_avg, exp_mov_avg];

  %  ***********************************************
  %   3. Code for computing Momentum
  %
  %

  %for i=1:size(closing_prices,1)-9
	  %momentum(i) = closing_prices(i) - closing_prices(i+9);
  %end
   
  %Vectorized implementation
  momentum = closing_prices(1:size(closing_prices,1)-9,1) - closing_prices(days:end);
  %momentum(1:3)
  % Pad zeroes at the end
  momentum = [momentum;zeros(days-1,1)];
  fprintf("\nComputed momentum")

  % Add momentum to the feature vector
  %featureVector = [simple_mov_avg, exp_mov_avg, momentum];


  %  ***********************************************
  %   4. Code for computing stochastic K%
  %
  %

  stochastic_k = zeros(sz);
  for i=1:sz-9
	minimum = min(low_prices(i:i+9,1));
	stochastic_k(i) = [( closing_prices(i) - minimum ) / ( max(high_prices(i:i+9,1)) - minimum )] * 100;
  end

  fprintf("\nComputed stochastic K percent");
  %stochastic_k(1)

  % Add stochastic_k to the feature vector
  %featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k];
  %size(featureVector);

  %  ***********************************************
  %   5. Code for computing stochastic D%
  %
  %
  
  stochastic_d = zeros(sz);
  for i = 1:sz-9
	stochastic_d(i) = mean(stochastic_k(i:i+days-1,1));
  end
   fprintf("\nComputed stochastic D percent");
  %mean(stochastic_k(12:21,1)) == stochastic_d(12)

  % Add stochastic_d to the feature vector
  %featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d];
  
  %  ***********************************************
  %   6. Code for computing Commodity Channel Index
  %
  %

  	mean_price = (closing_prices + high_prices + low_prices) / 3;
        size(mean_price);
	
        avg_mean_price = zeros(sz);
	for i = 1:sz-9
		 avg_mean_price(i) = mean(mean_price(i:i+days-1,1));
	end
        size(avg_mean_price);

        mean_deviation = zeros(sz);
        for i = 1:sz-9
		 mean_deviation(i) = mean(abs(mean_price(i:i+9,1) - avg_mean_price(i) * ones(days,1)) );
	end
	size(mean_deviation);
	
	% Problem with vector addition
	
	%commodity_channel_index = zeros(sz);
	%for i=1:sz-9	
        % Vectorized implementation
	        commodity_channel_index =  ( mean_price - avg_mean_price ) ./ (0.015 * mean_deviation);
	%end
	commodity_channel_index(1:10,1);
	% Replace Infs with zeroes
	commodity_channel_index(~isfinite(commodity_channel_index))=0;
        size(commodity_channel_index);
         fprintf("\nComputed Commodity Channel Index");
	% Add commodity_channel_index to the feature vector
	%featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d, commodity_channel_index];
  

  %  ***********************************************
  %   7. Code for Computing accumulation/distribution oscillator
  %
  %

  acc_dis_oscillator = zeros(sz);
  acc_dis_oscillator = (high_prices(1:sz(1)-1,1) - closing_prices(2:end,1)) ./ ( high_prices(1:sz(1)-1,1) - low_prices(1:sz(1)-1,1) );
  acc_dis_oscillator = [acc_dis_oscillator;0];
  acc_dis_oscillator(1) == (high_prices(1) - closing_prices(2)) / (high_prices(1) - low_prices(1));
  size(acc_dis_oscillator);
  acc_dis_oscillator(isnan(acc_dis_oscillator))=0;

   fprintf("\nComputed accumulation/distribution oscillator");
  % Add acc_dis_oscillator to the feature vector
  %featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d, commodity_channel_index, acc_dis_oscillator];


  %  ***********************************************
  %   8. Code for Computing Larry William's R%
  %
  %

  larry_williams_r = zeros(sz);
  for i=1:sz(1)-9
	maximum = max(high_prices(i:i+9,1));
	larry_williams_r(i) =  (maximum - closing_prices(i)) / (maximum - min(low_prices(i:i+9,1)) ) * 100;
  end     
  larry_williams_r(1:10,1);
  size(larry_williams_r);
  fprintf("\nComputed larry williams R percent");
  %featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d, commodity_channel_index, acc_dis_oscillator, larry_williams_r];

  %  ***********************************************
  %   9. Code for computing Relative Strength Index
  %
  %
  
  % Initialization
  rsi = zeros(sz);
  gain = zeros(sz(1));
  loss = zeros(sz(1));

  for i=1:sz(1)-1
  	diff = closing_prices(i) - closing_prices(i+1);
	if(diff > 0)
	  gain(i) = diff;
        else
          loss(i) = abs(diff);
	end
  end
  %fprintf("RSI");
  gain(1:10,1);
  loss(1:10,1);	
  size(rsi);
  % compute the average gain and average loss
  for i=1:sz-9
  	average_gain = mean(gain(i:i+9,1));
  	average_loss = mean(loss(i:i+9,1));
	if(average_loss != 0)
		rsi(i) = average_gain / average_loss;
	else
		rsi(i) = average_gain;
	end
  end

   fprintf("\nComputed relative strength index");
 % Add rsi to featureVector
 %featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d, commodity_channel_index, acc_dis_oscillator, larry_williams_r, rsi];
 
  %  ***********************************************
  %   10. Code for computing MACD
  %
  %
  macd = expMovAvg(data, 12) - expMovAvg(data, 26);
  %fprintf("MACD");
  size(macd);
  macd(isnan(macd))=0;
  fprintf("\nComputed Moving average convergence divergence");

   fprintf("\nConstructing feature vector");
  featureVector = [simple_mov_avg, exp_mov_avg, momentum, stochastic_k, stochastic_d, commodity_channel_index, acc_dis_oscillator, larry_williams_r, rsi, macd];
  fprintf("Done...");
end
