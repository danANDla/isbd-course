create table ingredient_types(
    id serial primary key,
    name varchar(50) not null,
);

/* ingredients
*/
create table ingredients(
    id serial primary key,
    name varchar(50) not null,
    description text,
    type serial,
    constraint FK_ingredient_types 
        foreign key(type)
            references ingredient_types(id)
            on delete set null,
);

/* products
   цена больше нуля */
create table products(
    id serial primary key,
    ingredient_id serial,
    constraint FK_ingredients 
        foreign key(ingredient_id)
            references ingredients(id)
            on delete set null,
    name varchar(50) not null,
    price real check (price > 0) not null,
    description text
);

/* cocktail_types
*/
create table cocktail_types(
    id serial primary key,
    name varchar(50) not null,
    description text
);

/* cocktails
*/
create table cocktails(
    id serial primary key,
    name varchar(50) not null,
    type_id serial,
    constraint FK_cocktail_types 
        foreign key(type_id)
            references cocktail_types(id)
            on delete set null,
    description text,
    recipe text
);

/* recipes | ingredients_to_cocktails
*/
create table recipes(
    ingredient_id serial,
    constraint FK_ingredients 
        foreign key(ingredient_id)
            references ingredients(id)
            on delete cascade,

    cocktail_id serial,
    constraint FK_cocktails 
        foreign key(cocktail_id)
            references cocktails(id)
            on delete cascade,

    quantity real check(quantity >= 0) not null,

    primary key(ingredient_id, cocktail_id)
);

/* parties
*/
create table parties(
    id serial primary key,
    name varchar(50) not null,
    event_date timestamp not null,
    location varchar(100) not null,
    description text
);

/* menus | parties_to_cocktails
*/
create table menus(
    party_id serial,
    constraint FK_parties 
        foreign key(party_id)
            references parties(id)
            on delete cascade,

    cocktail_id serial,
    constraint FK_cocktails 
        foreign key(cocktail_id)
            references cocktails(id)
            on delete cascade,

    primary key (party_id, cocktail_id)
);

/* purchases | parties_to_products  
*/ 
create table purchases(
    party_id serial,
    constraint FK_parties 
        foreign key(party_id)
            references parties(id)
            on delete cascade,

    product_id serial,
    constraint FK_products 
        foreign key(product_id)
            references products(id)
            on delete cascade,
    
    quantity real check(quantity >= 0) not null,

    primary key (party_id, product_id)
);


/* people
*/
create table people(
    id serial primary key,
    name varchar(50) not null
);

/* responsible | people_to_parties
*/
create table responsible(
    party_id serial,
    constraint FK_parties 
        foreign key(party_id)
            references parties(id)
            on delete cascade,

    person_id serial,
    constraint FK_people 
        foreign key(person_id)
            references people(id)
            on delete cascade,

    primary key (party_id, person_id)
);

/* invites | people_to_parties
*/
create table invites(
    party_id serial,
    constraint FK_parties 
        foreign key(party_id)
            references parties(id)
            on delete cascade,

    person_id serial,
    constraint FK_people 
        foreign key(person_id)
            references people(id)
            on delete cascade,

    primary key (party_id, person_id)
);

/* orders
*/
create table orders(
    id serial primary key,
    name varchar(50) not null,
    price real check (price >= 0) not null,
    
    party_id serial,
    constraint FK_parties 
        foreign key(party_id)
            references parties(id)
            on delete set null,

    person_id serial,
    constraint FK_people 
        foreign key(person_id)
            references people(id)
            on delete set null,


    cocktail_id serial,
    constraint FK_cocktails 
        foreign key(cocktail_id)
            references cocktails(id)
            on delete set null
);