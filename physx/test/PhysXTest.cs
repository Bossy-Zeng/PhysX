using UnityEngine;
using System.Runtime.InteropServices;

public class PhysXTest : MonoBehaviour
{
    private const string DLL_NAME = "PhysX";
    [DllImport(DLL_NAME)] private static extern int PhysX_Initialize();
    [DllImport(DLL_NAME)] private static extern void PhysX_Shutdown();
    [DllImport(DLL_NAME)] private static extern int PhysX_IsInitialized();
    [DllImport(DLL_NAME)] private static extern int PhysX_GetVersion();
    [DllImport(DLL_NAME)] private static extern float PhysX_SimulateBoxDrop(int numSteps);
    [DllImport(DLL_NAME)] private static extern int PhysX_GetVersionMajor();
    [DllImport(DLL_NAME)] private static extern int PhysX_GetVersionMinor();
    [DllImport(DLL_NAME)] private static extern int PhysX_GetVersionPatch();
    private bool _initialized = false;
    private string _statusText = "Waiting...";
    void Start() { TestPhysX(); }
    void OnDestroy() { if (_initialized) { PhysX_Shutdown(); } }
    void TestPhysX()
    {
        int r = PhysX_Initialize();
        if (r != 0) { _statusText = "Init FAILED: " + r; return; }
        _initialized = true;
        int major = PhysX_GetVersionMajor(), minor = PhysX_GetVersionMinor(), patch = PhysX_GetVersionPatch();
        float y60 = PhysX_SimulateBoxDrop(60), y120 = PhysX_SimulateBoxDrop(120), y300 = PhysX_SimulateBoxDrop(300);
        _statusText = string.Format("PhysX {0}.{1}.{2} OK\nBox@1s={3:F2}m\nBox@2s={4:F2}m\nBox@5s={5:F2}m", major, minor, patch, y60, y120, y300);
    }
    void OnGUI()
    {
        GUILayout.BeginArea(new Rect(10, 10, 400, 200));
        GUILayout.Label(_statusText);
        if (GUILayout.Button("Re-test", GUILayout.Height(40))) { if (_initialized) PhysX_Shutdown(); _initialized = false; TestPhysX(); }
        GUILayout.EndArea();
    }
}