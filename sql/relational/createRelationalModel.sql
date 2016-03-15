-- Create Relational Model Tables
drop table if exists agg_play;
drop table if exists player_play;
drop table if exists play;
drop table if exists drive;
drop table if exists game;
-- drop table if exists player;
-- drop table if exists team;

create table if not exists team (
	team_id					integer not null auto_increment,
    
    team_abbr				char(4) not null,
    team_name				varchar(128) not null,
    team_city				varchar(64) not null,
    team_division			varchar(10) not null,
    team_conference			char(3) not null,
    
    primary key (team_id)
);

create table if not exists player (
	player_id				integer not null auto_increment,
    team_id					integer not null,
    player_gsis				varchar(16) not null unique,
    
    player_first_name		varchar(64) not null,
    player_last_name		varchar(64) not null,
	player_position			char(4) not null,
    player_dob				varchar(64) not null,
    player_weight_lb		smallint unsigned not null,
    player_height_cm		smallint unsigned not null,
    player_college			varchar(64) not null,
    player_years_exp		tinyint unsigned not null,
    player_uniform_num		tinyint unsigned not null,
    player_status			varchar(32) not null,
    player_profile_url		varchar(512) not null,
	
    
    primary key (player_id),
    
    foreign key (team_id)
		references team(team_id)
);

create table if not exists game (
	game_id					integer not null auto_increment,
    game_eid				varchar(10) not null unique,
    
    home_team_id			integer not null,
    home_score_final		smallint unsigned not null,
    home_score_q1 			smallint unsigned not null,
    home_score_q2 			smallint unsigned not null,
    home_score_q3 			smallint unsigned not null,
    home_score_q4 			smallint unsigned not null,
    home_score_q5 			smallint unsigned not null,

    home_total_fds 			smallint not null,
    home_total_yds 			smallint not null,
    home_total_pass_yards 	smallint not null,
    home_total_rush_yards 	smallint not null,
    home_total_pens			smallint not null,
    home_total_pen_yards	smallint not null,
    home_time_of_pos		varchar(10) not null,
    home_turnovers			smallint not null,
    home_total_punts		smallint not null,
    home_total_punt_yards	smallint not null,
    home_total_punt_avg		smallint not null,
    
    away_team_id			integer not null,
    away_score_final		smallint unsigned not null,
    away_score_q1 			smallint unsigned not null,
    away_score_q2 			smallint unsigned not null,
    away_score_q3 			smallint unsigned not null,
    away_score_q4 			smallint unsigned not null,
    away_score_q5 			smallint unsigned not null,
    
    away_total_fds 			smallint not null,
    away_total_yds 			smallint not null,
    away_total_pass_yards 	smallint not null,
    away_total_rush_yards 	smallint not null,
    away_total_pens			smallint not null,
    away_total_pen_yards	smallint not null,
    away_time_of_pos		varchar(10) not null,
    away_turnovers			smallint not null,
    away_total_punts		smallint not null,
    away_total_punt_yards	smallint not null,
    away_total_punt_avg		smallint not null,
    
    game_week				tinyint not null,
    game_year				year(4) not null,
    game_type				char(4) not null,
    game_date				date not null,
    game_start_time			time not null,
    
    primary key (game_id),
    
    foreign key (home_team_id)
		references team(team_id),
        
	foreign key (away_team_id)
		references team(team_id)
);

create table if not exists drive (
	game_id					integer not null,
	drive_id				integer not null,
    team_id					integer not null,
    
    drive_pos_time			time not null,
    drive_total_plays 		tinyint unsigned not null,
    drive_first_downs		tinyint unsigned not null,
    drive_yards_gained		tinyint unsigned not null,
    drive_yards_pen			tinyint not null,
    drive_result			varchar(32) not null,
    			
	drive_start_time		time not null,
    drive_start_quarter		tinyint unsigned not null,
    drive_start_position	varchar(10) not null,
    
    drive_end_time			time not null,
    drive_end_quarter		tinyint unsigned not null,
    drive_end_position 		varchar(10) not null,
    
    primary key (game_id, drive_id),
    
    foreign key (game_id)
		references game(game_id),
        
	foreign key (team_id)
		references team(team_id)
);

create table if not exists play (
	game_id					integer not null,
    drive_id				integer not null,
	play_id					integer not null,
    team_id					integer not null,
    
    quarter					tinyint unsigned not null,
    down					tinyint unsigned not null,
    start_time				time not null,
    yard_line				varchar(10) not null,
    yards_to_first_down		tinyint unsigned not null,
	yards_this_drive		smallint not null,
    
    play_description		varchar(128) not null,
    play_note				varchar(64),
        
	first_down				tinyint(1) not null default 0,
    rushing_first_down		tinyint(1) not null default 0,
    passing_first_down		tinyint(1) not null default 0,
    
    penalty					tinyint(1) not null default 0,
    penalty_first_down		tinyint(1) not null default 0,
    
    third_down_att			tinyint(1) not null default 0,
    third_down_cmp			tinyint(1) not null default 0,
    
    fourth_down_att			tinyint(1) not null default 0, 
    fourth_down_cmp			tinyint(1) not null default 0,
    
    timeout					tinyint(1) not null default 0,
    xp_aborted				tinyint(1) not null default 0,
    
    primary key (game_id, drive_id, play_id),
    
    foreign key (game_id, drive_id)
		references drive(game_id, drive_id),
        
	foreign key (team_id)
		references team(team_id)
);

/*	
	Table: agg_play
    
    Description: Holds the aggregate statistics for a particular play. Has a one-to-one
	relationship with the play table. Prevents the need to perform aggregation
    multiple times. Has an attribute for each statistic a play can have.
    
    Play Categories:
		- Passing
        - Rushing
        - Receiving
        - Fumbles
        - Kicking
        - Punting
        - Kick Return
        - Punt Return 
        - Defense
        - Penalty
*/

create table if not exists agg_play (
	game_id					integer not null,
    drive_id				integer not null,
    play_id					integer not null,
    
    passing_att				smallint not null default 0,
    passing_cmp				smallint not null default 0,
    passing_cmp_air_yds		smallint not null default 0,
    passing_cmp_tot_yds		smallint not null default 0,
    passing_incmp			smallint not null default 0,
    passing_incmp_air_yds	smallint not null default 0,
    passing_int				smallint not null default 0,
    passing_sack			smallint not null default 0,
    passing_sack_yds		smallint not null default 0,
    passing_td				smallint not null default 0,
    passing_twopt_att		smallint not null default 0,
    passing_twopt_cmp		smallint not null default 0,
	passing_twopt_fail		smallint not null default 0,
	
	rushing_att				smallint not null default 0,
    rushing_yds				smallint not null default 0,
    rushing_loss			smallint not null default 0,
    rushing_loss_yds		smallint not null default 0,
    rushing_td				smallint not null default 0,
    rushing_twopt_att		smallint not null default 0,
    rushing_two_point_cmp	smallint not null default 0,
	rushing_two_point_fail	smallint not null default 0,

    receiving_rec			smallint not null default 0,
    receiving_target		smallint not null default 0,
    receiving_yac_yds		smallint not null default 0,
    receiving_tot_yds		smallint not null default 0,
    receiving_twopt_att		smallint not null default 0,
    receiving_twopt_cmp		smallint not null default 0,
    receiving_twopt_fail	smallint not null default 0,
    
    defence_tkl_ast			smallint not null default 0,
    defence_force_fum		smallint not null default 0,
    defence_fum_rec			smallint not null default 0,
    defence_fum_rec_tds		smallint not null default 0,
    defence_fum_rec_yds		smallint not null default 0,
    defence_int 			smallint not null default 0,
    defence_int_tds			smallint not null default 0,
    defence_int_yds			smallint not null default 0,
    defence_misc_tds		smallint not null default 0,
    defence_misc_yds		smallint not null default 0,
    defence_pass_def		smallint not null default 0,
    defence_punt_blk		smallint not null default 0,
    defence_qb_hit			smallint not null default 0,
    defence_fg_blk			smallint not null default 0,
	defence_safety			smallint not null default 0,
    defence_sack			smallint not null default 0,
    defence_sack_yds		smallint not null default 0,
    defence_tkl				smallint not null default 0,
    defence_tkl_loss		smallint not null default 0,
    defence_tkl_loss_yds	smallint not null default 0,
    defence_tkl_primary		smallint not null default 0,
    defence_xp_block		smallint not null default 0,
    
    fumble_forced			smallint not null default 0,
    fumble_lost				smallint not null default 0,
    fumble_unforced			smallint not null default 0,
    fumble_oob				smallint not null default 0,
    fumble_rec				smallint not null default 0,
    fumble_rec_tds			smallint not null default 0,
    fumble_rec_yds			smallint not null default 0,
    fumble_total			smallint not null default 0,
    
    kicking_all_yds			smallint not null default 0,
    kicking_downed			smallint not null default 0,
    kicking_fg_att			smallint not null default 0,
    kicking_fg_blk			smallint not null default 0,
    kicking_fg_blk_rec		smallint not null default 0,
    kicking_fg_blk_tds		smallint not null default 0,
    kicking_fg_cmp			smallint not null default 0,
    kicking_fg_cmp_yds		smallint not null default 0,
    kicking_fg_miss			smallint not null default 0,
    kicking_fg_miss_yds		smallint not null default 0,
    kicking_inside_20		smallint not null default 0,
    kicking_rec				smallint not null default 0,
    kicking_rec_tds			smallint not null default 0,
    kicking_total			smallint not null default 0,
    kicking_touchback		smallint not null default 0,
    kicking_xp_att			smallint not null default 0,
    kicking_xp_blk			smallint not null default 0,
    kicking_xp_cmp			smallint not null default 0,
    kicking_xp_miss			smallint not null default 0,
    kicking_yds				smallint not null default 0,
    
    kickret_fair_catch		smallint not null default 0,
    kickret_oob				smallint not null default 0,
    kickret_return			smallint not null default 0,
    kickret_tds				smallint not null default 0,
    kickret_touchback		smallint not null default 0,
    kickret_yds				smallint not null default 0,
    
    punting_blk				smallint not null default 0,
    punting_inside_20		smallint not null default 0,
    punting_total			smallint not null default 0,
    punting_touchback		smallint not null default 0,
    punting_yds				smallint not null default 0,
    
    puntret_faircatch		smallint not null default 0,
    puntret_downed			smallint not null default 0,
    puntret_oob				smallint not null default 0,
    puntret_tds				smallint not null default 0,
    puntret_total			smallint not null default 0,
    puntret_touchback		smallint not null default 0,
    puntret_yds				smallint not null default 0,
    
    primary key (game_id, drive_id, play_id),
    
    foreign key (game_id, drive_id, play_id)
		references play(game_id, drive_id, play_id)
);


/*	
	Table: player_play
    
    Description: Contains the statistics for a particular player within a single play.
	Has a relationship with both the play & player table. 
*/

create table if not exists player_play (
	game_id			integer not null,
    drive_id		integer not null,
    play_id			integer not null,
    player_id		integer not null,
    team_id			integer not null,
    sequence_num	integer not null,
    
    passing_att				smallint not null default 0,
    passing_cmp				smallint not null default 0,
    passing_cmp_air_yds		smallint not null default 0,
    passing_cmp_tot_yds		smallint not null default 0,
    passing_incmp			smallint not null default 0,
    passing_incmp_air_yds	smallint not null default 0,
    passing_int				smallint not null default 0,
    passing_sack			smallint not null default 0,
    passing_sack_yds		smallint not null default 0,
    passing_td				smallint not null default 0,
    passing_twopt_att		smallint not null default 0,
    passing_twopt_cmp		smallint not null default 0,
	passing_twopt_fail		smallint not null default 0,
	
	rushing_att				smallint not null default 0,
    rushing_yds				smallint not null default 0,
    rushing_loss			smallint not null default 0,
    rushing_loss_yds		smallint not null default 0,
    rushing_td				smallint not null default 0,
    rushing_twopt_att		smallint not null default 0,
    rushing_two_point_cmp	smallint not null default 0,
	rushing_two_point_fail	smallint not null default 0,

    receiving_rec			smallint not null default 0,
    receiving_target		smallint not null default 0,
    receiving_yac_yds		smallint not null default 0,
    receiving_tot_yds		smallint not null default 0,
    receiving_twopt_att		smallint not null default 0,
    receiving_twopt_cmp		smallint not null default 0,
    receiving_twopt_fail	smallint not null default 0,
    
    defence_tkl_ast			smallint not null default 0,
    defence_force_fum		smallint not null default 0,
    defence_fum_rec			smallint not null default 0,
    defence_fum_rec_tds		smallint not null default 0,
    defence_fum_rec_yds		smallint not null default 0,
    defence_int 			smallint not null default 0,
    defence_int_tds			smallint not null default 0,
    defence_int_yds			smallint not null default 0,
    defence_misc_tds		smallint not null default 0,
    defence_misc_yds		smallint not null default 0,
    defence_pass_def		smallint not null default 0,
    defence_punt_blk		smallint not null default 0,
    defence_qb_hit			smallint not null default 0,
    defence_fg_blk			smallint not null default 0,
	defence_safety			smallint not null default 0,
    defence_sack			smallint not null default 0,
    defence_sack_yds		smallint not null default 0,
    defence_tkl				smallint not null default 0,
    defence_tkl_loss		smallint not null default 0,
    defence_tkl_loss_yds	smallint not null default 0,
    defence_tkl_primary		smallint not null default 0,
    defence_xp_block		smallint not null default 0,
    
    fumble_forced			smallint not null default 0,
    fumble_lost				smallint not null default 0,
    fumble_unforced			smallint not null default 0,
    fumble_oob				smallint not null default 0,
    fumble_rec				smallint not null default 0,
    fumble_rec_tds			smallint not null default 0,
    fumble_rec_yds			smallint not null default 0,
    fumble_total			smallint not null default 0,
    
    kicking_all_yds			smallint not null default 0,
    kicking_downed			smallint not null default 0,
    kicking_fg_att			smallint not null default 0,
    kicking_fg_blk			smallint not null default 0,
	kicking_fg_blk_rec		smallint not null default 0,
    kicking_fg_blk_tds		smallint not null default 0,
    kicking_fg_cmp			smallint not null default 0,
    kicking_fg_cmp_yds		smallint not null default 0,
    kicking_fg_miss			smallint not null default 0,
    kicking_fg_miss_yds		smallint not null default 0,
    kicking_inside_20		smallint not null default 0,
    kicking_rec				smallint not null default 0,
    kicking_rec_tds			smallint not null default 0,
    kicking_total			smallint not null default 0,
    kicking_touchback		smallint not null default 0,
    kicking_xp_att			smallint not null default 0,
    kicking_xp_blk			smallint not null default 0,
    kicking_xp_cmp			smallint not null default 0,
    kicking_xp_miss			smallint not null default 0,
    kicking_yds				smallint not null default 0,
    
    kickret_fair_catch		smallint not null default 0,
    kickret_oob				smallint not null default 0,
    kickret_return			smallint not null default 0,
    kickret_tds				smallint not null default 0,
    kickret_touchback		smallint not null default 0,
    kickret_yds				smallint not null default 0,
    
    punting_blk				smallint not null default 0,
    punting_inside_20		smallint not null default 0,
    punting_total			smallint not null default 0,
    punting_touchback		smallint not null default 0,
    punting_yds				smallint not null default 0,
    
    puntret_faircatch		smallint not null default 0,
    puntret_downed			smallint not null default 0,
    puntret_oob				smallint not null default 0,
    puntret_tds				smallint not null default 0,
    puntret_total			smallint not null default 0,
    puntret_touchback		smallint not null default 0,
    puntret_yds				smallint not null default 0,
    
    primary key (game_id, drive_id, play_id, player_id),
    
    foreign key (game_id, drive_id, play_id)
		references play(game_id, drive_id, play_id),
        
	foreign key (player_id)
		references player(player_id),
        
	foreign key (team_id)
		references team(team_id)
);
