//
//  CalendarsRepository.swift
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

import EventKit
import Combine
import SwiftUI
import SyncTionCore
import PreludePackage

class EKEventsRepository {
    static let store = EKEventStore()
    static func requestAccess(to type: EKEntityType, result: @escaping (Result<Bool, Error>) -> Void) {
        Self.store.requestAccess(to: type) { granted, error in
            Task { @MainActor in
                if let error {
                    result(.failure(error))
                } else {
                    result(.success(granted))
                }
            }
        }
    }
}

final class CalendarsRepository: EKEventsRepository, FormRepository {
    static let shared = CalendarsRepository()

    var calendars: [Option] {
        Self.store.calendars(for: .event)
            .filter(\.allowsContentModifications)
            .map {
                Option(optionId: $0.calendarIdentifier, description: $0.title)
            }
    }

    func post(form: FormModel) async throws -> Void {
        let granted = try? await Self.store.requestAccess(to: .event)
        guard granted != nil else {
            logger.error("CalendarsRepository: post() Failed you dont have permissions")
            throw FormError.auth(CalendarsFormService.shared.id)
        }
        
        let event = EKEvent(eventStore: Self.store)
        let range: RangeTemplate? = form.inputs.first(tag: Tag.Calendars.RangeField)
        let list: OptionsTemplate? = form.inputs.first(tag: Tag.Calendars.CalendarsField)
        let note: TextTemplate? = form.inputs.first(tag: Tag.Calendars.NoteField)
        let title: TextTemplate? = form.inputs.first(tag: Tag.Calendars.TitleField)
        
        event.title = title?.value ?? "New event"
        event.startDate = range?.startDate
        event.endDate = range?.endDate
        event.notes = note?.value ?? ""
        
        if let optionId = list?.value.selected.first?.optionId {
            event.calendar = Self.store.calendar(withIdentifier: optionId)
        } else {
            event.calendar = Self.store.defaultCalendarForNewReminders()
        }
        
        do {
            try Self.store.save(event, span: .thisEvent)
            logger.info("CalendarsRepository: post() Saved")
        } catch {
            logger.error("CalendarsRepository: post() Failed on save - \(error)")
            throw FormError.api(.general(CodableError(error)))
        }
    }
    
    static var scratchTemplate: FormTemplate {
        let style = FormModel.Style(
            formName: CalendarsFormService.shared.description,
            icon: .static(CalendarsFormService.shared.icon, loadAsPng: false),
            color: Color.accentColor.rgba
        )
        let calendarsRange = RangeTemplate(
            header: Header(
                name: String(localized: "Event date"),
                icon: "calendar",
                tags: [Tag.Calendars.RangeField]
            ),
            config: InputTemplateConfig(mandatory: Editable(true, constant: true))
        )
        let calendarsNote = TextTemplate(
            header: Header(
                name: String(localized: "Note"),
                icon: "text.justify.leading",
                tags: [Tag.Calendars.NoteField]
            )
        )
        let calendarsTitle = TextTemplate(
            header: Header(
                name: String(localized: "Event name"),
                icon: "textformat.abc",
                tags: [Tag.Calendars.TitleField]
            )
        )
        let calendarsList = OptionsTemplate(
            header: Header(
                name: String(localized: "My calendars"),
                icon: "list.bullet",
                tags: [Tag.Calendars.CalendarsField]
            ),
            config: OptionsTemplateConfig(
                mandatory: Editable(true, constant: true),
                singleSelection: Editable(true, constant: true),
                typingSearch: Editable(false, constant: false)
            )
        )
        
        return FormTemplate(
            FormHeader(
                id: FormTemplateId(),
                style: style,
                integration: CalendarsFormService.shared.id
            ),
            inputs: [calendarsList, calendarsTitle, calendarsNote, calendarsRange]
        )
    }
}
