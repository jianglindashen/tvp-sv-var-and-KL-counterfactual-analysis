function result = select_var_lag(y, lag_max, type, season, exogen)
    % Validate input
    if any(isnan(y), 'all')
        error('NAs in y.');
    end

    [numObs, numVars] = size(y);
    lag_max = abs(floor(lag_max));
    type = validatestring(type, {'const', 'trend', 'both', 'none'});
    lag = lag_max + 1;
    
    % Create lagged variables
    ylagged = lagmatrix(y, 1:lag_max);
    ylagged = ylagged(lag:end, :);
    yendog = y(lag:end, :);
    sample = size(ylagged, 1);

    % Create RHS matrix based on the type
    switch type
        case 'const'
            rhs = ones(sample, 1);
        case 'trend'
            rhs = (lag_max + 1:sample + lag_max)';
        case 'both'
            rhs = [(lag_max + 1:sample + lag_max)', ones(sample, 1)];
        case 'none'
            rhs = [];
    end
    
    % Add seasonal dummies if specified
    if ~isempty(season)
        season = abs(floor(season));
        dum = (eye(season) - 1/season);
        dum(:, end) = [];
        dums = repmat(dum, ceil(sample/season), 1);
        dums = dums(1:sample, :);
        rhs = [rhs, dums];
    end
    
    % Add exogenous variables if specified
    if ~isempty(exogen)
        if size(exogen, 1) ~= numObs
            error('Different row size of y and exogen.');
        end
        rhs = [rhs, exogen(lag:end, :)];
    end
    
    if isempty(rhs)
        detint = 0;
    else
        detint = size(rhs, 2);
    end

    % Initialize criteria matrix
    criteria = nan(4, lag_max);
    
    % Loop through each lag length and estimate the VAR model
    for i = 1:lag_max
        ys_lagged = [ylagged(:, 1:numVars*i), rhs];
        nstar = size(ys_lagged, 2);
        resids = yendog - ys_lagged * (ys_lagged \ yendog);
        sigma = (resids' * resids) / sample;
        sigma_det = det(sigma);
        
        criteria(1, i) = log(sigma_det) + (2/sample) * (i * numVars^2 + numVars * detint); % AIC
        criteria(2, i) = log(sigma_det) + (2 * log(log(sample))/sample) * (i * numVars^2 + numVars * detint); % HQ
        criteria(3, i) = log(sigma_det) + (log(sample)/sample) * (i * numVars^2 + numVars * detint); % SC
        criteria(4, i) = ((sample + nstar) / (sample - nstar))^numVars * sigma_det; % FPE
    end

    % Find the lag length that minimizes each criterion
    [~, minAICLag] = min(criteria(1, :));
    [~, minHQLag] = min(criteria(2, :));
    [~, minSCLag] = min(criteria(3, :));
    [~, minFPELag] = min(criteria(4, :));
    
    order = [minAICLag, minHQLag, minSCLag, minFPELag];
    
    % Return results
    result.selection = order;
    result.criteria = criteria;
end
