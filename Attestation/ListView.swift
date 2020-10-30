//
//  ContentView.swift
//  Attestation
//
//  Created by Adrien Humiliere on 29/10/2020.
//

import SwiftUI
import CoreData

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Attestation.tripDate, ascending: false)],
        animation: .default)

    private var attestations: FetchedResults<Attestation>

    @State var showingCreationForm = false

    var body: some View {
        NavigationView {
            List {
                ForEach(attestations) { attestation in
                    NavigationLink(destination: AttestationView(attestation: attestation)) {
                        Text("Attestation du \(attestation.tripDate!, formatter: itemFormatter)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Attestations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showingCreationForm.toggle()
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }.sheet(isPresented: $showingCreationForm) {
                        CreateAttestationView(isPresented: $showingCreationForm) { formData in
                            DispatchQueue.main.async {
                                addAttestation(formData)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addAttestation(_ formData: AttestationFormData) {
        withAnimation {
            let newAttestation = Attestation(context: viewContext)
            newAttestation.creationDate = Date()
            newAttestation.firstName = formData.firstName
            newAttestation.lastName = formData.lastName
            newAttestation.birthDate = formData.birthDate
            newAttestation.birthPlace = formData.birthPlace
            newAttestation.address = formData.address
            newAttestation.city = formData.city
            newAttestation.postalCode = formData.postalCode
            newAttestation.tripDate = formData.tripDate
            newAttestation.reasonIdentifier = formData.reason
            newAttestation.reasonDescription = formData.reason

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { attestations[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}