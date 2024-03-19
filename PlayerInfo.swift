//
//  PlayerInfo.swift
//  OverDraft
//
//  Created by sawcleaver on 8/20/21.
//

import SwiftUI
import CoreData

func getWeeklyPoints(player: Player) -> [Double] {
    let weeklyPoints = [player.week1points,
                        player.week2points,
                        player.week3points,
                        player.week4points,
                        player.week5points,
                        player.week6points,
                        player.week7points,
                        player.week8points,
                        player.week9points,
                        player.week10points,
                        player.week11points,
                        player.week12points,
                        player.week13points,
                        player.week14points,
                        player.week15points,
                        player.week16points]
    return weeklyPoints
}

func getPlayerLabelString(player: Player, addition: String) -> String {
    let name = player.playerName!.padding(toLength: 25, withPad: " ", startingAt: 0)
    let pos = player.position!.uppercased().padding(toLength: 3, withPad: " ", startingAt: 0)
    let points = String(format: "%.1f", player.totalPoints).padding(toLength: 6, withPad: " ", startingAt: 0)
    let team = player.teamName!.padding(toLength: 6, withPad: " ", startingAt: 0)
    let vor = String(format: "%1.f", player.valueOverReplacement).padding(toLength: 6, withPad: " ", startingAt: 0)
    let bye = String(format: "%02d", player.byeWeek).padding(toLength: 4, withPad: " ", startingAt: 0)
    let label = "\(name) \(pos) V:\(vor) P:\(points) B:\(bye) \(team)"+addition
    
    return label
}
