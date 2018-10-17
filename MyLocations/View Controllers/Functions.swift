//
//  Functions.swift
//  MyLocations
//
//  Created by Ryan on 10/15/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
