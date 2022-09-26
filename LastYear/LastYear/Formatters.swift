//
//  Formatters.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.09.22.
//

import Foundation

public class Formatters {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    public static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd.MM.yyyy"
        return formatter
    }()
}
