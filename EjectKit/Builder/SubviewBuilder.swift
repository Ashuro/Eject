//
//  SubviewBuilder.swift
//  Eject
//
//  Created by Brian King on 10/19/16.
//  Copyright © 2016 Brian King. All rights reserved.
//

import Foundation

struct SubviewConfiguration: CodeGenerator {
    var objectIdentifier: String
    var subview: Reference

    var dependentIdentifiers: Set<String> {
        return [objectIdentifier, subview.identifier]
    }

    func generateCode(in document: XIBDocument) throws -> String? {
        let object = try document.lookupReference(for: objectIdentifier)
        let variable = document.variable(for: object)
        var representation = ""
        let subviewVariable = document.variable(for: subview)
        if object.definition.className == "UIStackView" {
            representation.append("\(variable).addArrangedSubview(\(subviewVariable))")
        }
        else {
            representation.append("\(variable).addSubview(\(subviewVariable))")
        }
        return representation
    }
}

struct SubviewBuilder: Builder, ContainerBuilder {

    func buildElement(attributes: inout [String: String], document: XIBDocument, parent: Reference?) throws -> Reference? {
        guard let parent = parent else { throw XIBParser.Error.needParent }
        return parent
    }

    func didAddChild(object: Reference, to parent: Reference, document: XIBDocument) throws {
        guard !document.placeholders.contains(object.identifier) else {
            // If the object is a placeholder, assume that it has already been added to the view hierarchy.
            return
        }
        try document.addStatement(
            for: object.identifier,
            generator: SubviewConfiguration(objectIdentifier: parent.identifier, subview: object),
            phase: .subviews
        )
    }

}
