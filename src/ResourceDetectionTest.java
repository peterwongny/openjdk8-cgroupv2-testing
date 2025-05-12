public class ResourceDetectionTest {
    public static void main(String[] args) {
        // Print JVM version
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("Java VM Name: " + System.getProperty("java.vm.name"));
        System.out.println("Java VM Version: " + System.getProperty("java.vm.version"));
        
        // Print detected CPU resources
        System.out.println("\n=== CPU Resources ===");
        System.out.println("Available processors: " + Runtime.getRuntime().availableProcessors());
        
        // Print detected memory resources
        System.out.println("\n=== Memory Resources ===");
        System.out.println("Max memory: " + humanReadableByteCount(Runtime.getRuntime().maxMemory()));
        System.out.println("Total memory: " + humanReadableByteCount(Runtime.getRuntime().totalMemory()));
        System.out.println("Free memory: " + humanReadableByteCount(Runtime.getRuntime().freeMemory()));
        
        // Print container-specific JVM flags
        printJVMFlags();
        
        // Print relevant system properties
        printContainerProperties();
    }
    
    private static String humanReadableByteCount(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        String pre = "KMGTPE".charAt(exp-1) + "";
        return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
    }
    
    private static void printJVMFlags() {
        System.out.println("\n=== JVM Container Flags ===");
        try {
            java.lang.management.RuntimeMXBean runtimeMxBean = java.lang.management.ManagementFactory.getRuntimeMXBean();
            java.util.List<String> arguments = runtimeMxBean.getInputArguments();
            for (String arg : arguments) {
                System.out.println(arg);
            }
        } catch (Exception e) {
            System.out.println("Error getting JVM flags: " + e.getMessage());
        }
    }
    
    private static void printContainerProperties() {
        System.out.println("\n=== Container-Related System Properties ===");
        System.getProperties().forEach((k, v) -> {
            if (k.toString().contains("container") || k.toString().contains("cgroup"))
                System.out.println(k + ": " + v);
        });
    }
}
