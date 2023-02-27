insert into ingredients(name)
values('белый ром'),
('лаймовый сок'),
('сахарный сироп'),
('кола'),
('текила'),
('апельсиновый сок'),
('гренадин'),
('сливки'),
('кокосовый сироп'),
('ананасовый сок'),
('апельсиновый ликёр');

insert into ingredient_types(name)
values ('spirits'),
('juices'),
('drinks'),
('produce'),
('syrups'),
('undef');

insert into products(ingredient_id, name, price)
values(1, 'Barcelo blanco', 1.279),
(2, 'homemade', 0.224),
(3, 'Barinoff', 0.381),
(4, 'Coca-cola', 0.111),
(5, 'Sierra', 2.14),
(6, 'Сады Придония', 0.15),
(7, 'Barline', 0.5),
(8, 'Простоквашино', 0.397),
(9, 'Richeza', 1.058),
(10, 'Rich', 0.183),
(11, 'Monin Triple Sec', 2.413),
(1, 'Cointreau', 1.927);

insert into cocktail_types(name)
values ('Ancestrals'),
('Sours'),
('Spirit-Forward Cocktails'),
('Duos and Trios'),
('Champagne Cocktails'),
('Highballs, Collinses, and Fizzes'),
('Juleps and Smashes'),
('Hot Drinks'),
('Flips and Nogs'),
('Pousse Family'),
('Tropical-Style Drinks'),
('Punch'),
('Old (and Odd) Birds'),
('sour'),
('tiki');

insert into cocktails(name, type_id)
values('Daiquiri', 1),
('Pina Colada', 2),
('Margarita', 1);

insert into recipes(cocktail_id, ingredient_id, quantity)
values
/* Daiquiri */
(1, 1, 60),
(1, 2, 30),
(1, 3, 15),

/* Margarita */
(3, 1, 50),
(3, 11, 25),
(3, 2, 30),
(3, 3, 10),

/* Pina Colada */
(2, 1, 40),
(2, 2, 10),
(2, 9, 20),
(2, 10, 100);

insert into parties(name, event_date, location)
values('ITMOtion', '2022-09-04 22:00:00+03', 'ГК');

insert into purchases(party_id, product_id, quantity)
values(1, 1, 40),
(1, 3, 1000),
(1, 2, 500),
(1, 6, 2000),
(1, 7, 1000),
(1, 5, 900);

insert into people(name)
values('Dora'),
('Nikita'),
('Tyoma'),
('Julia'),
('Danya');

insert into menus(party_id, cocktail_id)
values(1,1);

insert into invites(person_id, party_id)
values(1,1);