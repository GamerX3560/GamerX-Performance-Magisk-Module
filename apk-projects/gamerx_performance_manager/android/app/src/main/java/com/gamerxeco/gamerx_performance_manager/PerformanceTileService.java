package com.gamerxeco.gamerx_performance_manager;

import android.graphics.drawable.Icon;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;
import android.content.Intent;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.IOException;

public class PerformanceTileService extends TileService {
    
    private static final String PREFS_NAME = "FlutterSharedPreferences";
    private static final String CURRENT_PROFILE_KEY = "flutter.current_profile";
    
    private String[] profiles = {"Battery Saver", "Balanced", "Gaming", "Turbo Gaming"};
    private String[] profileIds = {"battery_saver", "balanced", "gaming", "turbo_gaming"};
    
    @Override
    public void onStartListening() {
        super.onStartListening();
        updateTile();
    }
    
    @Override
    public void onClick() {
        super.onClick();
        
        // Get current profile
        String currentProfile = getCurrentProfile();
        
        // Find next profile
        int currentIndex = 0;
        for (int i = 0; i < profileIds.length; i++) {
            if (profileIds[i].equals(currentProfile)) {
                currentIndex = i;
                break;
            }
        }
        
        int nextIndex = (currentIndex + 1) % profileIds.length;
        String nextProfile = profileIds[nextIndex];
        
        // Apply next profile
        applyProfile(nextProfile);
        
        // Update tile
        updateTile();
        
        // Show notification (launch main app)
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("profile_applied", profiles[nextIndex]);
        startActivity(intent);
    }
    
    private String getCurrentProfile() {
        try {
            File file = new File(getFilesDir(), "current_profile.txt");
            if (file.exists()) {
                BufferedReader reader = new BufferedReader(new FileReader(file));
                String profile = reader.readLine();
                reader.close();
                return profile != null ? profile : "Balanced";
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "Balanced";
    }
    
    private void applyProfile(String profile) {
        try {
            String engineProfile = profile.toLowerCase().replace(" ", "_");
            
            Process process = Runtime.getRuntime().exec(new String[]{
                "su", "-c", "/system/bin/gamerx_perf_engine apply " + engineProfile
            });
            int exitCode = process.waitFor();
            
            if (exitCode == 0) {
                File file = new File(getFilesDir(), "current_profile.txt");
                FileWriter writer = new FileWriter(file);
                writer.write(profile);
                writer.close();
            }
            
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
    
    private void updateTile() {
        Tile tile = getQsTile();
        if (tile != null) {
            String currentProfile = getCurrentProfile();
            
            tile.setLabel(currentProfile);
            tile.setState(Tile.STATE_ACTIVE);
            
            // Set icon based on current profile
            String profileLower = currentProfile.toLowerCase();
            if (profileLower.contains("battery")) {
                tile.setIcon(Icon.createWithResource(this, android.R.drawable.ic_lock_power_off));
            } else if (profileLower.contains("gaming")) {
                tile.setIcon(Icon.createWithResource(this, android.R.drawable.ic_media_play));
            } else {
                tile.setIcon(Icon.createWithResource(this, android.R.drawable.ic_menu_manage));
            }
            
            tile.updateTile();
        }
    }
}
