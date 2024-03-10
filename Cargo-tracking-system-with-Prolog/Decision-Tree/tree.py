from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import export_text

# Load Iris dataset
iris = load_iris()
X = iris.data
y = iris.target

# Create a Decision Tree Classifier
clf = DecisionTreeClassifier()
clf.fit(X, y)

# Export the decision tree to text format
tree_rules = export_text(clf, feature_names = iris.feature_names)

# göstermek amaçlı karar ağacının normal halini de oluşturuyoruz.
with open("decision_tree.txt", "w") as file:

    for fact in tree_rules:

        file.write(fact)

# Prolog bilgi tabanı oluşturma
prolog_facts = []

# Convert data to Prolog "fact" format
for i in range(len(iris.target)):

    features = ",".join(map(str, iris.data[i]))
    fact = f"iris({features},{iris.target_names[iris.target[i]].lower()})."
    prolog_facts.append(fact)

# Write the Prolog knowledge base to the file

with open("knowledge_base.pl", "w") as file:

    for fact in prolog_facts:

        file.write(fact + "\n")
