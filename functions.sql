/*Добавить коктейль в заказ*/
create or replace procedure add_item_to_order(in p_id bigint, in c_id bigint, in u_id bigint, in isCheck boolean, inout order_id bigint) as $$
declare
    mview record;
    remain real;
    new_quantity real;
    price real;
    c_name text;
    prod record;
begin
    price := 0;

    select cocktails.name from cocktails where cocktails.id = c_id into c_name;
    execute format('insert into orders(name,price,party_id,person_id,cocktail_id,ischecked)
            values($1,$2,$3,$4,$5,$6) returning id;') into order_id using c_name, 0, p_id,u_id,c_id, isCheck; 

    for mview in 
        select cocktails.name as cocktail, ingredients.name as ingredient, recipes.quantity as quantity, ingredients.id as ingr_id from ingredients
            JOIN recipes on recipes.ingredient_id = ingredients.id
            JOIN cocktails on cocktails.id = recipes.cocktail_id
        where cocktails.id = c_id 
    loop
        select purchases.quantity from ingredients
            join products on products.ingredient_id = ingredients.id
            join purchases on purchases.product_id = products.id
        where purchases.party_id = p_id and ingredients.id = mview.ingr_id order by purchases.quantity desc limit 1 into remain;
        new_quantity:= remain - mview.quantity;
        RAISE NOTICE '[%] ✓ % %, will remain -> %',
                     mview.cocktail,
                     mview.ingredient,
                     mview.quantity,
                     new_quantity;

        select products.id as id, products.price as price from ingredients
            join products on products.ingredient_id = ingredients.id
            join purchases on purchases.product_id = products.id
        where purchases.party_id = p_id and ingredients.id = mview.ingr_id order by purchases.quantity desc limit 1 into prod;


        execute format('update purchases set quantity = $2 where product_id = $1 and party_id = $3;')
            using prod.id, new_quantity, p_id; 

        price := price + (mview.quantity * prod.price);
    end loop;  
    RAISE NOTICE 'price = %', price;
    execute format('update orders set price = $2 where orders.id = $1;')
        using order_id, price; 
    return;
end;
$$ language plpgsql;


/*Добавить продукт в purchases*/
create or replace procedure add_product_to_purchase(p_id bigint, prod_id bigint, quantity real) as $$
declare
    remain real;
    new_quantity real;
begin
    
    if prod_id not in(
        select product_id from purchases where purchases.party_id = p_id
    )
    then
        execute format('insert into purchases(party_id,product_id,quantity)
                values($1,$2,$3);') using p_id, prod_id, 0; 
    end if;

    select purchases.quantity from ingredients
        join products on products.ingredient_id = ingredients.id
        join purchases on purchases.product_id = products.id
    where purchases.party_id = p_id and products.id = prod_id into remain;

    new_quantity := remain + quantity;
    execute format('update purchases set quantity = $2 where product_id = $1 and party_id = $3;')
        using prod_id, new_quantity, p_id; 

end;
$$ language plpgsql;

/* Get number of cocktails that could be prepared from available stocks */
create or replace function get_available_cocktails(p_id bigint) 
returns table (
    cocktail_id bigint,
    quantity int
)
as $$
declare
    mview record;
    menuItem record;
    remain real;
    new_quantity real;
    min_quantity integer;
    result integer;
    price real;
    c_name text;
    ret integer[];
begin
    price := 0;
    min_quantity := 999999;

    for menuItem in
        select menus.cocktail_id as cocktailId from menus
        where menus.party_id = p_id
    loop
        min_quantity := 999999;
        new_quantity := 0;
        for mview in 
            select cocktails.name as cocktail, ingredients.name as ingredient, recipes.quantity as quantity, ingredients.id as ingr_id from ingredients
                JOIN recipes on recipes.ingredient_id = ingredients.id
                JOIN cocktails on cocktails.id = recipes.cocktail_id
            where cocktails.id = menuItem.cocktailId 
        loop
            if mview.ingr_id in(
                select ingredients.id from ingredients
                    join products on products.ingredient_id = ingredients.id
                    join purchases on purchases.product_id = products.id
                where purchases.party_id = p_id
            )
            then
                select purchases.quantity from ingredients
                    join products on products.ingredient_id = ingredients.id
                    join purchases on purchases.product_id = products.id
                where purchases.party_id = p_id and products.ingredient_id = mview.ingr_id order by purchases.quantity desc limit 1 into remain;

                new_quantity:= remain / mview.quantity;
                if new_quantity < min_quantity
                then
                    min_quantity := new_quantity;
                end if;
                if remain < mview.quantity
                then
                    min_quantity := 0;
                end if;
            else
                min_quantity := 0;
            end if;
        end loop;  
        
        RAISE NOTICE '[%] %',
                     mview.cocktail,
                     min_quantity;

        cocktail_id := menuItem.cocktailId;
        quantity := min_quantity;
        return next;
    end loop;


end;
$$ language plpgsql;

/* get products needed for cocktail*/
create or replace function get_needed_ingredients(p_id bigint, c_id bigint) 
returns table (
    ingredient_id bigint,
    remain real
)
as $$
declare
    mview record;
    old_quantity real;
    new_quantity real;
    result integer;
    price real;
    c_name text;
begin
    result := 1;

    for mview in 
        select cocktails.name as cocktail, ingredients.name as ingredient, recipes.quantity as quantity, ingredients.id as ingr_id from ingredients
            JOIN recipes on recipes.ingredient_id = ingredients.id
            JOIN cocktails on cocktails.id = recipes.cocktail_id
        where cocktails.id = c_id 
    loop
        if mview.ingr_id in(
            select ingredients.id from ingredients
                join products on products.ingredient_id = ingredients.id
                join purchases on purchases.product_id = products.id
            where purchases.party_id = p_id
        )
        then
            select purchases.quantity from ingredients
                join products on products.ingredient_id = ingredients.id
                join purchases on purchases.product_id = products.id
            where purchases.party_id = p_id and products.ingredient_id = mview.ingr_id order by purchases.quantity desc limit 1 into old_quantity;

            new_quantity:= old_quantity - mview.quantity;
            if new_quantity < 0
            then
                ingredient_id := mview.ingr_id;
                remain := old_quantity;
                return next;
            end if;
        else
            ingredient_id := mview.ingr_id;
            remain := 0;
            return next;
        end if;
    end loop;  
end;
$$ language plpgsql;