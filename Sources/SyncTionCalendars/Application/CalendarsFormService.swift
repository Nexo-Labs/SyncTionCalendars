//
//  CalendarsFormService.swift
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
import Foundation

public final class CalendarsFormService: FormService {
    
    public static let shared = CalendarsFormService()

    public var id = FormServiceId(hash: UUID(uuidString: "b920ba94-4667-48fd-862e-59d2c9284c44")!)

    public let description = String(localized: "Calendars")
    public let icon = "CalendarsLogo"
    
    private let repository = CalendarsRepository.shared

    
    public let onChangeEvents: [any TemplateEvent] = []

    public func load(form: FormModel) async throws -> FormDomainEvent {
        guard var input: OptionsTemplate = form.inputs.first(tag: .Calendars.CalendarsField) else {
            throw FormError.nonLocatedInput(.Calendars.CalendarsField)
        }
        
        let calendars = repository.calendars
        input.load(options: calendars, keepSelected: false)
        return { [input] form in
            form.inputs[input.id] = AnyInputTemplate(input)
        }
    }
    
    public func send(form: FormModel) async throws {
        try await repository.post(form: form)
    }
    
    public var scratchTemplate: FormTemplate {
        CalendarsRepository.scratchTemplate
    }
}
