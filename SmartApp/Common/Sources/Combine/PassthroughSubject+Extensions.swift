//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Combine

public typealias Trigger = PassthroughSubject<Void, Never>

public extension PassthroughSubject where Output == Void, Failure: Error {
    func trigger() {
        send(())
    }
}
