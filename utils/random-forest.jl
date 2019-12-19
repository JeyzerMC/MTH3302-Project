using CSV, DataFrames, Statistics, Dates, Random, MLBase, DecisionTree;

function find_best_rf(train_set, validation_set, features, params)
    best_params = nothing;
    best_f1_score = 0;

    train_features = convert(Matrix{Float64}, train_set[:, features]);
    train_labels = convert(Array{Int64}, train_set[!,:SURVERSE]);

    val_features = convert(Matrix{Float64}, validation_set[:, features]);
    val_labels = convert(Array{Int64}, validation_set[!,:SURVERSE]);

    for nft = params[1, :min]:params[1, :step]:params[1, :max]
        for ntrees = params[2, :min]:params[2, :step]:params[2, :max]
            for podata = params[3, :min]:params[3, :step]:params[3, :max]
                for maxd = params[4, :min]:params[4, :step]:params[4, :max]
                    f1_score = 0;
                    for niter=1:2
                        # Build forest
                        train_model = build_forest(train_labels, train_features, nft, ntrees, podata / 100, maxd);

                        # Validate forest
                        val_pred = apply_forest(train_model, val_features);
                        r = roc(val_labels, val_pred);
                        f1_score += f1score(r);
                    end

                    f1_score /= 2;

                    if f1_score > best_f1_score
                        best_params = [nft, ntrees, podata, maxd];
                        best_f1_score = f1_score;
                    end
                end
            end
        end
    end

    return best_params, best_f1_score;
end


function get_rf_probas(train_set, validation_set, features, params) 
    train_features = convert(Matrix{Float64}, train_set[:, features]);
    train_labels = convert(Array{Int64}, train_set[!,:SURVERSE]);

    val_features = convert(Matrix{Float64}, validation_set[:, features]);

    train_model = build_forest(train_labels, train_features, params[1], params[2], params[3] / 100, params[4]);

    return apply_forest_proba(train_model, val_features);
end