def convert_into_proposition(predicate: str):
    if predicate == "\n":
        return ""
    functor, args = predicate.rstrip(').\n').split("(")
    args = args.split('","')
    for index in range(len(args)):
        args[index] = args[index].strip('"').replace(" ", "").replace("-","")
    if functor == "isParent":
        args[0] = args[0][0].lower() + args[0][1:]
        return args[0] + functor[0].upper() + functor[1:] + "Of" + args[1]
    else:
        return args[0][0].lower() + args[0][1:] + functor[0].upper() + functor[1:]


predicates = []
with open("language-database.pl") as database:
    predicates.extend(map(convert_into_proposition, database.readlines()))

with open("language-database-propositional.pl", "w") as output:
    for predicate in predicates:
        output.write(predicate + ".\n")