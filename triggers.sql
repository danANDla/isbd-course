/* проверка есть ли коктейль в меню вечеринки*/
create or replace function check_cocktail_in_menu() returns trigger as $$
begin
    if new.cocktail_id not in (select cocktail_id from menus where party_id = new.party_id)
    then
        RAISE EXCEPTION 'cocktail is not in menus of this party';
    end if;
    return new;
end;
$$ language plpgsql;
create or replace trigger check_cocktail_in_menu_trigger
    before insert or update on orders
    for each row
execute procedure check_cocktail_in_menu();
 
/* проверка приглашен ли пользователь */
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