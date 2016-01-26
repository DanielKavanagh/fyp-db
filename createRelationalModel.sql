-- Create Relational Model Tables
drop table if exists drive;
drop table if exists game;
drop table if exists play;
drop table if exists team;
drop table if exists player;

create table if not exists team (
	team_id			integer not null,
    
    primary key (team_id)
);

create table if not exists player (
	player_id		integer auto_increment not null,
    
    primary key (player_id)
);

create table if not exists game (
	game_id			integer not null,
    
    home_team_id	integer not null,
    away_team_id	integer not null,
    
    primary key (game_id),
    
    foreign key (home_team_id)
		references team(team_id),
        
	foreign key (away_team_id)
		references team(team_id)
);

create table if not exists drive (
	drive_id		integer not null,
    game_id			integer not null,
    
    primary key (game_id, drive_id),
    
    foreign key (game_id)
		references game(game_id)
);