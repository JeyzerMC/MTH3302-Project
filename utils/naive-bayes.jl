function compareArr(a, b, verbose)
    pourcent = count(a .== b)/size(a,1) * 100;
    if(verbose)
        println(size(a,1))
        println(size(b,1))
        
        println("Le modéle est précis à $pourcent %");
    end
    return pourcent;
end

#= fonction qui trouve la distribution qui représente le mieux un ensemble de donnée=#

function fitBestLikelihoodDistribution(data::Array, verbose::Bool)
    # Définition des distributions à essayer
    distributions = [Beta, Binomial, 
              Categorical, DiscreteUniform, Exponential, 
              Normal, Gamma, Geometric, Laplace, Pareto, 
              Poisson, Uniform, Multinomial, MvNormal, Dirichlet, Weibull];
    
    distributionNames = ["Beta", "Binomial", 
                  "Categorical", "DiscreteUniform", "Exponential", 
                  "Normal", "Gamma", "Geometric", "Laplace", "Pareto", 
                  "Poisson", "Uniform", "Multinomial", "MvNormal", "Dirichlet", "Weibull"];
    
    # Déclaration des variables
    maxLikelihood = -Inf;
    distributionName = nothing;
    finalFitDistribution = nothing;
    fitDistribution = nothing;
    
    for i = 1:length(distributions) # Pour chaque type de distribution
        if (verbose)
            println("Trying model of type: ", distributionNames[i]);
        end
        try # On essaie de faire fit la distribution sur les données
            fitDistribution = fit(distributions[i], data);
        catch
            if (verbose)
                println("Invalid");
            end
            continue
        end
        
        newLikelihood = loglikelihood(fitDistribution, data)
        
        # Si on trouve une meilleure logvraisemblance que celle qu'on a déjà, 
        # la distribution courante est le meilleure
        if (newLikelihood > maxLikelihood) 
            maxLikelihood = newLikelihood;
            distributionName = distributionNames[i];
            finalFitDistribution = fitDistribution;
        end
    end
    
    println("The best distribution is of type ", distributionName, " with a likelihood of ", maxLikelihood)
    return finalFitDistribution;
end

#= Cette fonction retourne un tableau des meilleurs distributions selon les variables explicatives données 
(une distribution lorsqu'il n'y a pas de surverse et 
une distribution lorsqu'il y a surverse pour chaque variabe explicative)=#

function getBestLikelihoodDistributions(train::DataFrame, variable::Symbol)
    x_m = [];
    for i=0:1
        ind = train[:,:SURVERSE] .== i;
        x=train[ind,variable];
        push!(x_m,fitBestLikelihoodDistribution(x, false));
    end
    
    return x_m;
end

function fitModel(train::DataFrame, variables::Array{Symbol} )
    likelihoodDistrs = Dict();
    
    for variable in variables
        likelihoodDistrs[variable] = getBestLikelihoodDistributions(train, variable);
    end
    return likelihoodDistrs
end

#=fonction permettant de récupérer un a priori en se basant sur la distribution d'un ensemble de données. =#
function getPrioris(trainSet::DataFrame)
    dAlpha = trainSet[:,:SURVERSE];
    n_mode = Float64[];
    for i=0:1
        push!(n_mode, count(dAlpha .== i));
    end
    α = n_mode/size(trainSet,1);
    
    return α;
end

#= fonction permettant de faire une prédiction sur les données à 
l'aide des distributions et de la loi a priori fourni. =#
function predictNaiveBayes(data::DataFrame, likelihoodDistrs::Array, prioris::Array, variables::Array)
    n_data = size(data,1);
    nb_exp_var = size(variables,1);
    y_m = Array{Int64}(undef,n_data);

    for i=1:n_data
        p = [];
        for j=1:2
#             prob =1; # à priori non informatif (Uniform(0,1))
            prob = prioris[j]
            for k=1:nb_exp_var
                prob *= pdf.(likelihoodDistrs[k][j], data[i,variables[k]]);
            end
            push!(p,prob);
        end
        _, ind = findmax(p);
        y_m[i] =ind -1;
    end
    
    return y_m;
end

function BIC(distributions::Dict, data::DataFrame)
    n = size(data)[1]
    k = length(keys(distributions))
    totalLogLikelihood = 0
    for variable in keys(distributions)
        for j=0:1
            ind = data[:,:SURVERSE] .== j;
            x=data[ind,variable];
            totalLogLikelihood += loglikelihood(distributions[variable][j+1], x)
        end
    end
    return (totalLogLikelihood - k*log(n)/2);
end

function findBestVariablesCombinationBIC(train::DataFrame, likelihoodDistrs::Dict, variables::Array{Symbol})
    bics = []
    bicsDict = Dict()
    combinations = []
    for combination in subsets(variables)
        push!(combinations, combination)
        modelVariables = []
        modelLikelihoodDistrs = Dict()
        for variable in combination
            modelLikelihoodDistrs[variable] = likelihoodDistrs[variable]
        end
        bic = BIC(modelLikelihoodDistrs, train)
        if bic == 0.0
            continue
        end
        push!(bics, bic)
    end
    _, indexMax = findmax(bics)
    println("Best combination: ", combinations[indexMax], " with bic: ", bics[indexMax])
    return (combinations[indexMax], bics[indexMax])
end

function findBestVariablesCombinationF1Validation(train::DataFrame, validation::DataFrame, likelihoodDistrs::Dict, variables::Array{Symbol})
    f1scores = []
    combinations = []
    for combination in subsets(variables)
        push!(combinations, combination)
        modelVariables = []
        modelLikelihoodDistrs = []
        for variable in combination
            push!(modelLikelihoodDistrs, likelihoodDistrs[variable])
            push!(modelVariables, variable)
        end
        prioris = getPrioris(train)
#         @show modelVariables
        y = predictNaiveBayes(validation, modelLikelihoodDistrs, prioris, modelVariables);
        r = roc(validation[:SURVERSE], y);
        push!(f1scores, f1score(r))
#         println(f1score(r))
    end
    _, indexMax = findmax(f1scores)
    println("Best combination: ", combinations[indexMax], " with f1score: ", f1scores[indexMax])
    return (combinations[indexMax], f1scores[indexMax])
end