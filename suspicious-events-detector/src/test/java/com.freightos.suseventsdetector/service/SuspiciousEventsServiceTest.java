package com.freightos.suseventsdetector.service;

import java.net.URL;
import java.util.List;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.freightos.suseventsdetector.model.UnauthorizedUser;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@ExtendWith(SpringExtension.class)
@SpringBootTest
public class SuspiciousEventsServiceTest {

    @Autowired
    private SuspiciousEventsService suspiciousEventsService;

    @Test
    public void captureUnauthorizedRequests() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        List<UnauthorizedUser> expectedUnauthorizedResponse = mapper.readValue(new URL("file:src/test/resources/service/unauthorized_users_response.json"), new TypeReference<List<UnauthorizedUser>>(){});
        List<UnauthorizedUser> actualUnauthorizedResponse = suspiciousEventsService.getUnauthorizedRequests("\"isAuthorized\": true", 3);

        assertNotNull(expectedUnauthorizedResponse);
        assertNotNull(actualUnauthorizedResponse);

        assertEquals(mapper.readTree(mapper.writeValueAsString(expectedUnauthorizedResponse)), mapper.readTree(mapper.writeValueAsString(actualUnauthorizedResponse)));
    }
}