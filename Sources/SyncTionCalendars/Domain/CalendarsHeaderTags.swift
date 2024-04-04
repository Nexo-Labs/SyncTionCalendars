//
//  CalendarsHeaderType.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 3/1/23.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import SyncTionCore

extension Tag {
    struct Calendars {
        private init() { fatalError() }

        static let CalendarsField = Tag("d542cc63-106f-46c8-9199-a5b133d74466")!
        static let TitleField = Tag("ec0ef079-8ebc-4a6b-b235-0265024fd4f2")!
        static let NoteField = Tag("5654a5be-bb40-401e-8cd9-5b937442eee5")!
        static let RangeField = Tag("c5f99969-31ac-4ad8-8a72-ec9ddbae4014")!
    }
}
