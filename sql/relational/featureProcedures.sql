delimiter //

drop procedure if exists aggregateHomeTeamWinRate//
drop procedure if exists aggregateAwayTeamWinRate//
drop procedure if exists aggregateOverallTeamWinRate//

/*Aggregates the home win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateHomeTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) as home_win_rate from (select * from game 
		where home_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonHomeGames
	where home_score_final > away_score_final
    into winRate;
end //

/*Aggregates the away win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateAwayTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) from (select * from game 
		where away_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonAwayGames
	where away_score_final > home_score_final
    into winRate;
end //

create procedure aggregateOverallTeamWinRate(in teamID int, in gameID int, in numGames int)
begin
	call aggregateHomeTeamWinRate(teamID, gameID, numGames / 2, @homeWinRate);
    call aggregateAwayTeamWinRate(teamID, gameID, numGames / 2, @awayWinRate);
    
    select (@homeWinRate + @awayWinRate) / 2;
end //
delimiter ;

call aggregateHomeTeamWinRate(22, 1792, 8, @a);

call aggregateAwayTeamWinRate(22, 1792, 8, @a);
call aggregateOverallTeamWinRate(22, 1792, 16);