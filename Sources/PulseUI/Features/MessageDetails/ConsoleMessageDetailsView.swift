// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

struct ConsoleMessageDetailsView: View {
    let message: LoggerMessageEntity

#if os(iOS)
    var body: some View {
        contents
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: trailingNavigationBarItems)
    }

    @ViewBuilder
    private var trailingNavigationBarItems: some View {
        HStack {
            NavigationLink(destination: ConsoleMessageMetadataView(message: message)) {
                Image(systemName: "info.circle")
            }
            PinButton(viewModel: .init(message), isTextNeeded: false)
        }
    }
#elseif os(watchOS)
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                NavigationLink(destination: ConsoleMessageMetadataView(message: message)) {
                    Label("Details", systemImage: "info.circle")
                }
                contents
            }
        }
    }
#elseif os(tvOS)
    var body: some View {
        contents
    }
#elseif os(macOS)
    @State private var selectedTab: ConsoleMessageTab = .message
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            selectedTabView
        }
    }

    private var toolbar: some View {
        HStack {
            HStack {
                InlineTabBarItem(title: "Message", isSelected: selectedTab == .message) {
                    selectedTab = .message
                }
                Divider()
                InlineTabBarItem(title: "Metadata", isSelected: selectedTab == .metadata) {
                    selectedTab = .metadata
                }
            }.fixedSize()
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
            }.buttonStyle(.plain)
        }.padding(EdgeInsets(top: 7, leading: 10, bottom: 6, trailing: 10))
    }

    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case .message:
            RichTextView(viewModel: makeTextViewModel())
        case .metadata:
            ConsoleMessageMetadataView(message: message)
        }
    }

#warning("implement")

    private enum ConsoleMessageTab: String, Identifiable {
        case message
        case metadata

        var id: ConsoleMessageTab { self }
    }
#endif

    private var contents: some View {
        VStack {
            RichTextView(viewModel: makeTextViewModel())
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func makeTextViewModel() -> RichTextViewModel {
        RichTextViewModel(string: TextRenderer().preformatted(message.text))
    }
}

#if DEBUG
struct ConsoleMessageDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsoleMessageDetailsView(message: makeMockMessage(), onClose: {})
        }
    }
}

func makeMockMessage() -> LoggerMessageEntity {
    let entity = LoggerMessageEntity(context: LoggerStore.mock.viewContext)
    entity.text = "test"
    entity.createdAt = Date()
    entity.label = "auth"
    entity.level = LoggerStore.Level.critical.rawValue
    entity.file = "LoggerStore.swift"
    entity.function = "createMockMessage()"
    entity.line = 12
    entity.rawMetadata = "customKey: customValue"
    return entity
}
#endif
