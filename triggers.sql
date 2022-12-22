/* Проверка есть ли коктейль в меню вечеринки */
create or replace function check_cocktail_in_menu() returns trigger as $$
begin
    if new.cocktail_id not in (select cocktail_id from menus where party_id = new.party_id)
    then
        RAISE EXCEPTION 'cocktail is not in the menu of this party';
    end if;
    return new;
end;
$$ language plpgsql;
create trigger a_check_cocktail_in_menu_trigger
    before insert or update on orders
    for each row
execute procedure check_cocktail_in_menu();

/* Проверка наличия ингредиентов для коктейля */
create or replace function check_ingredients_in_purchase() returns trigger as $$
declare
    mview record;
    remain real;
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
        where cocktails.id = new.cocktail_id 
    loop
        if mview.ingr_id in(
            select ingredients.id from ingredients
                join products on products.ingredient_id = ingredients.id
                join purchases on purchases.product_id = products.id
            where purchases.party_id = new.party_id
        )
        then
            select purchases.quantity from ingredients
                join products on products.ingredient_id = ingredients.id
                join purchases on purchases.product_id = products.id
            where purchases.party_id = new.party_id and products.ingredient_id = mview.ingr_id order by purchases.quantity desc limit 1 into remain;

            new_quantity:= remain - mview.quantity;
            if new_quantity < 0
            then
                RAISE NOTICE '[%] ~ % %',
                             mview.cocktail,
                             mview.ingredient,
                             mview.quantity;
                result := 0;
            end if;
        else
            RAISE NOTICE '[%] ☓ % %',
                         mview.cocktail,
                         mview.ingredient,
                         mview.quantity;
            result := 0;
        end if;
    end loop;  
    
    if result = 0
    then
        RAISE EXCEPTION 'not enough ingredients for this cocktail';
    end if;

    return new;
end;
$$ language plpgsql;
create trigger b_check_ingredients_in_purchase_trigger
    before insert or update on orders
    for each row
execute procedure check_ingredients_in_purchase();

/* Проверка приглашен ли пользователь */
create or replace function check_user_invited() returns trigger as $$
begin
    if new.person_id not in (select person_id from invites where party_id = new.party_id)
    then
        RAISE EXCEPTION 'user is not invited';
    end if;
    return new;
end;
$$ language plpgsql;
create trigger check_user_invited_trigger
    before insert or update on orders
    for each row
execute procedure check_user_invited();

/* Проверка есть ли продукт */
create or replace function check_product() returns trigger as $$
begin
    if new.product_id not in(
        select id from products
    )
    then
        RAISE EXCEPTION 'invalid product id';
    end if;
    return new;
end;
$$ language plpgsql;
create trigger check_product_trigger
    before insert or update on purchases
    for each row
execute procedure check_product();

/* Проверка обновленного количества */
create or replace function check_quantity_update() returns trigger as $$
declare
remain real;
new_quantity real;
begin
    
    select purchases.quantity from ingredients
        join products on products.ingredient_id = ingredients.id
        join purchases on purchases.product_id = products.id
    where purchases.party_id = new.party_id and products.id = new.product_id into remain;

    new_quantity := remain + new.quantity;
    if new_quantity < 0
    then
        RAISE EXCEPTION 'new value of quantity can not be negative:';
    end if;

    return new;
end;
$$ language plpgsql;
create trigger check_quantity_update_trigger
    before insert or update on purchases
    for each row
execute procedure check_quantity_update();
