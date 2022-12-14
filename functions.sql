/*Добавить коктейль в заказ*/
create or replace procedure add_item_to_order(p_id bigint, c_id bigint, u_id bigint) as $$
declare
    mview record;
    remain real;
    new_quantity real;
    price real;
    c_name text;
    prod record;
    order_id bigint;
begin
    price := 0;

    select cocktails.name from cocktails where cocktails.id = c_id into c_name;
    execute format('insert into orders(name,price,party_id,person_id,cocktail_id)
            values($1,$2,$3,$4,$5) returning id;') into order_id using c_name, 0, p_id,u_id,c_id; 

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