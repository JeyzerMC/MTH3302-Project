<a id="5.3."></a>

### 5.3. Améliorations possibles

Dans cette section, nous allons donner quelques pistes de solution afin de possiblement améliorer notre solution. Pour la plupart, se sont des idées que nous avons eu durant la durée du projet, mais que nous n'avons pas eu le temps d'implémenter. Les pistes qui suivent sont aussi des choses que nous aurrions pu faire au lieu de certain choix arbitraires effectués durant le développement de nos solutions.

<a id="5.3.1."></a>

#### 5.3.1 Données manquantes de précipitations

Nous avions tout d'abbord commencé par remplacer toutes les données manquantes par 0. C'était le choix le plus rapide d'implémantation. Par la suite, nous avons opté avec la moyenne journalière de la station. Nous ne sommes toujours pas convaincu que c'est la meilleur approche. L'imputation des données manquantes dans ce cas précis est vraiment complexe dû à la nature de problème de time-series auquel ont fait face. Considérons le cas où il pleut beaucoup en matiné et le ciel se dégage en fin de journée et qu'il nous manque un point de donnée à 22h00, est-ce la réalité de cette heure de précipitation est vraiment la moyenne cette journée, ou bien elle s'apparente plus à une moyenne entre l'heure précédente et l'heure suivante ? Nous aurions aussi pu prendre en compte les autres stations de météo. Est-ce le fait qu'il pleut beaucoup à McTavish veut dire qu'il pleut beaucoup aussi à Assomption ? Et Saint-Hubert ? C'est un peu ce que nous avons fait dans la [section 3.4.4.](#3.4.4.), mais nous avions utiliser que deux stations, nous aurions peut-être tiré davantage d'information en incluant toutes les stations. Surtout pour les stations où il manque une journée entière de données. Est-ce que c'est plus une combinaison des données des autres stations et de la tendance intrinsincte de la station ciblée ? Est-ce qu'il aurait fallu plutôt faire un modèle nous aidant à mieux prédire et choisir la quantité de pluie manquante dans à une station et une heure donnée sachant le contexte météo de cette heure ? Bref, nous aurions pu utiliser beaucoup plus de techniques que celles que nous avons utilisées.

<a id="5.3.2."></a>

#### 5.3.2 Données des journées alentours

Afin de faire suite au contexte d'une station, nous aurions pu aussi prendre en compte s'il y a eu surverse durant les jours précédents. En effet, puisque les surverses que l'ont prend en compte sont ceux du à la quantité de pluie tombée et que cette pluie s'accumule dans des réservoirs à taille fixe, est-ce que le fait qu'il ait plue beaucoup la veille sans surverse augemente les chances que du lendemain de surverser ? Il ne serait pas impossible de penser ainsi. De plus, est-ce qu'il est possible de surverser 3-4-5 jours de suite ? Est-ce que le fait d'avoir surversé la veille, décroit les chances de surverser le lendemain ? Ce sont toutes des questions que nous sommes dans l'impossibilité de répondre et qui aurait peut-être aidé notre modèle à mieux prédire les surverses d'un ouvrage. 

<a id="5.3.3."></a>

#### 5.3.3 Remplacement des données abérantes de précipitation

En troisième lieu, nous avons décidé arbitrairement de fixé le plafond des quantitiés de pluie tombé afin de ne pas avoir de données abérantes. Ces seuils ont été choisi arbitrairement après analyse des données. Nous aurions pu utilisé des techniques plus mathématiques que simplement utilisé un seuil fixe arbitraire. Par exemple, nous aurions pu trouver les données abérantes par clustering des données. Nous aurions pu appliquer un algorithme DBSCAN [https://en.wikipedia.org/wiki/DBSCAN] qui prend en paramètre la distance maximale entre deux points afin de dire s'il fait partie ou non du / des clusters de données. À l'aide de cette algorithme, nous aurions pu identifé potentiellement des seuils plus juste mathématiquement. De plus, nous aurions pu faire cette exercice par station par fonction d'aggrégation. Une autre amélioration qu'on aurait pu faire est de prendre en compte les données abérantes avant de les aggréger, et non une fois aggrégé. Ceci réduierait peut-être les énormes pics de données pour certaines fonctions d'aggrégations.  De plus, nous aurions pu aussi détecter les données abérantes avec une méthode plus statistique. Nous aurions pu essayé de faire *fitter* une loi normale sur nos données de précipitation et désider d'un seuil sur cette courbe qui ne serait pas acceptable (retirer les 5% des des données les plus élevés par exemple).

<a id="5.3.4."></a>

#### 5.3.4 Explorer plus de procédés d'aggrégation pour les précipitations

En effet, nous avons utilisé que 3 fonctions d'aggrégations afin de représenter les précipitations quotidiennes pour un ouvrage. Est-ce qu'on aurait eu avantage à en utiliser davantage / en utiliser des différentes. Nous aurions pu par exemple utiliser la moyenne quotidienne, la médianne quotidienne ou bien le mode. Nous aurions pu aussi *binner* nos précipitations. Cette hypothèse vient de l'échelle de nos données (au dixième de millimètres). Est-ce qu'il y a une différence significative entre 1 et 2 dixième de millimètre afin de surverser ? Entre 1 et 10 dixième de millimètre ? Nous aurions pu alors déterminer des catégories (bins) de précipitation par jour, et ainsi peut-être rendre le travail des modèles plus facile, même si durant cette transformation, nous perdrons la granularité et la continuité des résultats. De plus, au lieu de considéré les données de précipitation de la station la plus proche, ou une combinaison des stations les plus proche, tout simplement inclure toutes les stations dans les features.

<a id ="5.3.5."></a>

#### 5.3.5. Jeu de données additionnelles

Même si nous avions un jeu de donnée assez complexe et volumineux, il y a certaines informations qu'on aurait pu bénéficier. En effet, savoir la superficie qu'un ouvrage dessert aurait été utile. Supposons que l'eau de 100 km² se retrouve dans un ouvrage, et que seulement 1 km² se retouve dans un autre ouvrage, lequel des deux à le plus de chance de surverser ? Effectivement, puisqu'on parle de bassin de trop-plein du système des égouts de Montréal, il devrait être possible de savoir quelles conduites d'égoûts se déverse dans ce trop-plein, et donc le territoire couvert par ce réseau d'égout. De plus, avoir les dimmensions exactes des trop-plein aurait aider, ainsi que leur niveau d'eau courant. Pour une même quantité de pluie tombé, un même ouvrage pourrait surverser dépandement du niveau d'eau auquel il commence cette journée. 


<a id="5.3.6."></a>

#### 5.3.6 Types de modèles utilisés

À ce niveau, nous avons essayer plusieurs modèles et techniques de modèles probabilistes (Naive Bayes) et linéaire (Régression Logistique) ainsi de des modèles d'ensemble (Random Forest). Nous avons même essayer de recombiner certain modèle afin d'avoir un meilleur résultat. Nous avons aussi essayé plusieurs hyperparamètres pour les modèles où il avait lieu d'être. Il est certain qu'une bonne *grid search* [https://en.wikipedia.org/wiki/Hyperparameter_optimization#Grid_search] en bonne et du forme pourrait nous aider afin de mieux détermer qu'elle type de modèle utiliser, mais dans le cadre du devoir, nous avons juger qu'il n'était pas nécessaire d'en faire une. Il resterait peut-être à essayer les modèles neuronaux, mais ceux-ci dépasse largement le cadre du cours MTH3302. 