package world.qode;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.util.Map;

// The app serves at the root of its own hostname. Health is SmallRye Health's
// /q/health (fleet.conf HEALTH_PATH), fed by MyLivenessCheck.
@Path("/")
public class RootResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, String> root() {
        return Map.of("app", "quarkus-template", "status", "ok");
    }
}
