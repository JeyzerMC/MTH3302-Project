using CSV, DataFrames, Statistics, Dates, Random, MLBase, DecisionTree;

function find_best_threshold(val_pred, val_labels) 
    best_threshold = 0;
    best_f1_score = 0;

    for threshold=0.05:0.05:0.95
        tmp_pred = zeros(Int8, size(val_pred, 1));
        tmp_pred[val_pred .>= threshold] .= 1;

        r = roc(val_labels, tmp_pred);
        current_score = f1score(r);

        if current_score > best_f1_score
            best_threshold = threshold;
            best_f1_score = current_score;
        end
    end

    return best_threshold, best_f1_score;
end

function evaluate_threshold(val_pred, val_labels, threshold) 
    tmp_pred = zeros(Int8, size(val_pred, 1));
    tmp_pred[val_pred .>= threshold] .= 1;

    r = roc(val_labels, tmp_pred);
    return f1score(r);
end