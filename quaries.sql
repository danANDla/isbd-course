/*вывести ингредиенты коктейля и их количество*/
select cocktails.name as cocktail, ingredients.name as ingredient, recipes.quantity from ingredients
    JOIN recipes on recipes.ingredient_id = ingredients.id
    JOIN cocktails on cocktails.id = recipes.cocktail_id
where cocktails.id = 1;


/*товары, которые закупили к тусе*/
select ingredients.id, ingredients.name, products.name, purchases.quantity from ingredients
    join products on products.ingredient_id = ingredients.id
    join purchases on purchases.product_id = products.id
where purchases.party_id = 1;
