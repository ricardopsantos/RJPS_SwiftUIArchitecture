//
//  File.swift
//
//
//  Created by Ricardo Santos on 23/07/2024.
//

import Foundation

import XCTest
import Combine
import Nimble
import Common

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?
