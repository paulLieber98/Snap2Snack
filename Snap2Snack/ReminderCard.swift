import SwiftUI

struct ReminderCard: View {
    let reminder: Reminder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(reminder.time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: reminder.type == .glucose ? "heart.fill" : "pills.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}