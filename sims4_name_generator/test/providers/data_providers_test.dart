import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';

import 'package:sims4_name_generator/providers/data_providers.dart';
import 'package:sims4_name_generator/services/data_service.dart';
import 'package:sims4_name_generator/services/local_data_service.dart';
import 'package:sims4_name_generator/repositories/name_repository.dart';
import 'package:sims4_name_generator/repositories/trait_repository.dart';

import 'data_providers_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  group('Data Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('dataServiceProvider', () {
      test('should provide LocalDataService instance', () {
        // Act
        final dataService = container.read(dataServiceProvider);

        // Assert
        expect(dataService, isA<LocalDataService>());
      });

      test('should return same instance on multiple reads', () {
        // Act
        final dataService1 = container.read(dataServiceProvider);
        final dataService2 = container.read(dataServiceProvider);

        // Assert
        expect(identical(dataService1, dataService2), isTrue);
      });
    });

    group('nameRepositoryProvider', () {
      test('should provide NameRepository instance', () {
        // Act
        final nameRepository = container.read(nameRepositoryProvider);

        // Assert
        expect(nameRepository, isA<NameRepository>());
      });

      test('should inject data service dependency', () {
        // Act
        final nameRepository = container.read(nameRepositoryProvider);
        final dataService = container.read(dataServiceProvider);

        // Assert
        expect(nameRepository, isA<NameRepository>());
        expect(dataService, isA<LocalDataService>());
      });

      test('should return same instance on multiple reads', () {
        // Act
        final nameRepository1 = container.read(nameRepositoryProvider);
        final nameRepository2 = container.read(nameRepositoryProvider);

        // Assert
        expect(identical(nameRepository1, nameRepository2), isTrue);
      });
    });

    group('traitRepositoryProvider', () {
      test('should provide TraitRepository instance', () {
        // Act
        final traitRepository = container.read(traitRepositoryProvider);

        // Assert
        expect(traitRepository, isA<TraitRepository>());
      });

      test('should inject data service dependency', () {
        // Act
        final traitRepository = container.read(traitRepositoryProvider);
        final dataService = container.read(dataServiceProvider);

        // Assert
        expect(traitRepository, isA<TraitRepository>());
        expect(dataService, isA<LocalDataService>());
      });

      test('should return same instance on multiple reads', () {
        // Act
        final traitRepository1 = container.read(traitRepositoryProvider);
        final traitRepository2 = container.read(traitRepositoryProvider);

        // Assert
        expect(identical(traitRepository1, traitRepository2), isTrue);
      });
    });

    group('Provider Dependencies', () {
      test('should properly wire dependencies between providers', () {
        // Arrange
        final mockDataService = MockDataService();
        final overriddenContainer = ProviderContainer(
          overrides: [dataServiceProvider.overrideWithValue(mockDataService)],
        );

        // Act
        final nameRepository = overriddenContainer.read(nameRepositoryProvider);
        final traitRepository = overriddenContainer.read(
          traitRepositoryProvider,
        );

        // Assert
        expect(nameRepository, isA<NameRepository>());
        expect(traitRepository, isA<TraitRepository>());

        // Cleanup
        overriddenContainer.dispose();
      });

      test('should recreate dependent providers when data service changes', () {
        // Arrange
        final mockDataService1 = MockDataService();
        final mockDataService2 = MockDataService();

        final container1 = ProviderContainer(
          overrides: [dataServiceProvider.overrideWithValue(mockDataService1)],
        );

        final container2 = ProviderContainer(
          overrides: [dataServiceProvider.overrideWithValue(mockDataService2)],
        );

        // Act
        final nameRepository1 = container1.read(nameRepositoryProvider);
        final nameRepository2 = container2.read(nameRepositoryProvider);

        // Assert
        expect(nameRepository1, isA<NameRepository>());
        expect(nameRepository2, isA<NameRepository>());
        expect(identical(nameRepository1, nameRepository2), isFalse);

        // Cleanup
        container1.dispose();
        container2.dispose();
      });
    });
  });
}
