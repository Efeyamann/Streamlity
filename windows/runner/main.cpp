#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  // Geliştirme kolaylığı: STREAMLITY_WINDOW="x,y" ya da "x,y,genişlik,yükseklik"
  // pencereyi o konumda (ör. ikinci monitörde) açar.
  wchar_t window_env[64];
  if (::GetEnvironmentVariableW(L"STREAMLITY_WINDOW", window_env, 64) > 0) {
    int x, y, width, height;
    const int count =
        swscanf_s(window_env, L"%d,%d,%d,%d", &x, &y, &width, &height);
    if (count >= 2) {
      origin = Win32Window::Point(x, y);
    }
    if (count == 4) {
      size = Win32Window::Size(width, height);
    }
  }
  if (!window.Create(L"streamlity", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
